import { Request, Response, NextFunction } from 'express';
import { JwtUtil } from '../utils/jwt.util';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        email: string;
        role: string;
      };
    }
  }
}

/**
 * Middleware to authenticate JWT tokens
 */
export const authenticateToken = async (req: Request, res: Response, next: NextFunction) => {
  try {
    console.log('Auth middleware - Checking authorization header:', req.headers.authorization);
    
    const token = JwtUtil.extractToken(req.headers.authorization);

    if (!token) {
      console.log('Auth middleware - No token found');
      return res.status(401).json({ error: 'Access token required' });
    }

    console.log('Auth middleware - Token found, verifying...');
    const decoded = JwtUtil.verify(token);
    console.log('Auth middleware - Token decoded:', { userId: decoded.userId, email: decoded.email });

    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: { id: true, email: true, role: true, isActive: true }
    });

    console.log('Auth middleware - User lookup result:', {
      userId: decoded.userId,
      userFound: !!user,
      userActive: user?.isActive,
      userRole: user?.role
    });

    if (!user || !user.isActive) {
      console.log('Auth middleware - User not found or inactive');
      return res.status(401).json({ error: 'Invalid token' });
    }

    req.user = {
      id: user.id,
      email: user.email,
      role: user.role
    };

    console.log('Auth middleware - Success, req.user set:', req.user);
    next();
  } catch (error) {
    console.log('Auth middleware - Error:', error);
    return res.status(401).json({ error: 'Invalid token' });
  }
};

/**
 * Middleware pour authentification optionnelle - ne bloque pas la requête si pas de token
 */
export const optionalAuthenticateToken = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const token = JwtUtil.extractToken(req.headers.authorization);

    if (!token) {
      // Pas de token, mais on continue (utilisateur non authentifié)
      console.log('OptionalAuth middleware - No token, continuing as public user');
      return next();
    }

    try {
      const decoded = JwtUtil.verify(token);
      
      const user = await prisma.user.findUnique({
        where: { id: decoded.userId },
        select: { id: true, email: true, role: true, isActive: true }
      });

      if (user && user.isActive) {
        // Utilisateur authentifié trouvé
        req.user = {
          id: user.id,
          email: user.email,
          role: user.role
        };
        console.log('OptionalAuth middleware - User authenticated:', req.user);
      }
    } catch (error) {
      // Token invalide, mais on continue (utilisateur non authentifié)
      console.log('OptionalAuth middleware - Invalid token, continuing as public user');
    }
    
    next();
  } catch (error) {
    console.log('OptionalAuth middleware - Error:', error);
    next();
  }
};

// Alias pour compatibilité
export const authenticate = authenticateToken;
export const authMiddleware = authenticateToken;
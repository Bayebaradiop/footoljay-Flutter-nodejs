import { Request, Response } from 'express';
export declare class AdminController {
    getDashboardStats(req: Request, res: Response): Promise<void>;
    getAllProducts(req: Request, res: Response): Promise<void>;
    approveProduct(req: Request, res: Response): Promise<void>;
    rejectProduct(req: Request, res: Response): Promise<void>;
    deleteProduct(req: Request, res: Response): Promise<void>;
    getAllUsers(req: Request, res: Response): Promise<void>;
    toggleUserStatus(req: Request, res: Response): Promise<void>;
    updateUserRole(req: Request, res: Response): Promise<Response<any, Record<string, any>>>;
    toggleVipStatus(req: Request, res: Response): Promise<void>;
    deleteUser(req: Request, res: Response): Promise<Response<any, Record<string, any>>>;
    getUserDetails(req: Request, res: Response): Promise<Response<any, Record<string, any>>>;
}
declare const _default: AdminController;
export default _default;
//# sourceMappingURL=admin.controller.d.ts.map
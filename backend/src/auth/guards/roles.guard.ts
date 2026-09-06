import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../../common/decorators/roles.decorator';
import { AuthUser } from '../../common/decorators/current-user.decorator';

/**
 * RBAC guard (spec §80, §119). Authorization is enforced server-side,
 * never by hiding routes on the client.
 */
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<Array<'user' | 'admin'>>(
      ROLES_KEY,
      [context.getHandler(), context.getClass()],
    );
    if (!required || required.length === 0) return true;

    const user = context.switchToHttp().getRequest().user as AuthUser | undefined;
    if (!user || !required.includes(user.role)) {
      throw new ForbiddenException('You do not have access to this resource.');
    }
    return true;
  }
}

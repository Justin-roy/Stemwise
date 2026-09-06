import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

/**
 * Wraps every successful response in the standard STEMWISE envelope (spec §60).
 * If a handler already returns { data, meta }, meta is preserved for list responses.
 */
@Injectable()
export class ResponseInterceptor<T> implements NestInterceptor<T, unknown> {
  intercept(_ctx: ExecutionContext, next: CallHandler<T>): Observable<unknown> {
    return next.handle().pipe(
      map((payload: unknown) => {
        if (
          payload &&
          typeof payload === 'object' &&
          'data' in (payload as Record<string, unknown>) &&
          'meta' in (payload as Record<string, unknown>)
        ) {
          const p = payload as { data: unknown; meta: unknown };
          return { success: true, data: p.data, meta: p.meta };
        }
        return { success: true, data: payload, message: 'Success' };
      }),
    );
  }
}

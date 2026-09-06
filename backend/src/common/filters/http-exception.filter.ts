import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

/**
 * Normalizes all errors into the STEMWISE error envelope (spec §60).
 * Never leaks stack traces or internal details to clients.
 */
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger('Exception');

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Something went wrong.';
    let code = 'INTERNAL_ERROR';
    let errors: unknown[] = [];

    if (exception instanceof HttpException) {
      statusCode = exception.getStatus();
      const res = exception.getResponse();
      if (typeof res === 'string') {
        message = res;
      } else if (res && typeof res === 'object') {
        const r = res as Record<string, unknown>;
        const rawMessage = r.message;
        if (Array.isArray(rawMessage)) {
          errors = rawMessage;
          message = 'Please complete the highlighted fields.';
          code = 'VALIDATION_ERROR';
        } else if (typeof rawMessage === 'string') {
          message = rawMessage;
        }
        if (typeof r.code === 'string') code = r.code;
      }
    } else if (exception instanceof Error) {
      this.logger.error(`${request.method} ${request.url} — ${exception.message}`);
    }

    if (statusCode >= 500) {
      this.logger.error(`${request.method} ${request.url} — ${statusCode} ${message}`);
    }

    response.status(statusCode).json({
      success: false,
      statusCode,
      message,
      code,
      errors,
    });
  }
}

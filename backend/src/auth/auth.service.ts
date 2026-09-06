import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService, JwtSignOptions } from '@nestjs/jwt';
import * as argon2 from 'argon2';
import { ProfilesService } from '../profiles/profiles.service';
import { UserDocument } from '../users/schemas/user.schema';
import { UsersService } from '../users/users.service';
import { LoginDto, RegisterDto } from './dto/auth.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly users: UsersService,
    private readonly profiles: ProfilesService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {}

  async register(dto: RegisterDto) {
    const existing = await this.users.findByEmailWithSecret(dto.email);
    if (existing) throw new ConflictException('An account with this email already exists.');

    const passwordHash = await argon2.hash(dto.password);
    const user = await this.users.create(dto.email, passwordHash);
    await this.profiles.create(user.id, { name: dto.name });
    return this.issueTokens(user);
  }

  async login(dto: LoginDto) {
    const user = await this.users.findByEmailWithSecret(dto.email);
    if (!user) throw new UnauthorizedException('Invalid email or password.');
    const valid = await argon2.verify(user.passwordHash, dto.password);
    if (!valid) throw new UnauthorizedException('Invalid email or password.');
    return this.issueTokens(user);
  }

  async refresh(refreshToken: string) {
    let payload: { sub: string };
    try {
      payload = await this.jwt.verifyAsync(refreshToken, {
        secret: this.config.get<string>('jwt.refreshSecret'),
      });
    } catch {
      throw new UnauthorizedException('Invalid refresh token.');
    }

    const user = await this.users.findByIdWithRefresh(payload.sub);
    if (!user || !user.refreshTokenHash) {
      throw new UnauthorizedException('Invalid refresh token.');
    }
    const matches = await argon2.verify(user.refreshTokenHash, refreshToken);
    if (!matches) throw new UnauthorizedException('Invalid refresh token.');

    return this.issueTokens(user);
  }

  async logout(userId: string) {
    await this.users.setRefreshTokenHash(userId, null);
    return { loggedOut: true };
  }

  /**
   * Password reset is stubbed to avoid leaking whether an email exists and
   * because email delivery is out of scope here (spec §46). Always returns success.
   */
  forgotPassword() {
    return {
      message:
        'If an account exists for that email, a password reset link has been sent.',
    };
  }

  private async issueTokens(user: UserDocument) {
    const payload = { sub: user.id, email: user.email, role: user.role };
    const accessToken = await this.jwt.signAsync(payload, {
      secret: this.config.get<string>('jwt.accessSecret'),
      expiresIn: this.config.get<string>('jwt.accessExpiresIn'),
    } as JwtSignOptions);
    const refreshToken = await this.jwt.signAsync(payload, {
      secret: this.config.get<string>('jwt.refreshSecret'),
      expiresIn: this.config.get<string>('jwt.refreshExpiresIn'),
    } as JwtSignOptions);
    await this.users.setRefreshTokenHash(user.id, await argon2.hash(refreshToken));

    return {
      accessToken,
      refreshToken,
      user: { id: user.id, email: user.email, role: user.role },
    };
  }
}

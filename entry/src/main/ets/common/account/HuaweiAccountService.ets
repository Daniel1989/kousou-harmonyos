import { common } from '@kit.AbilityKit';
import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';

export interface HuaweiAccountSession {
  userId: string;
  unionID: string;
  openID: string;
  nickName: string;
  avatarUri: string;
  email: string;
  authorizationCode: string;
  idToken: string;
  state: string;
}

interface HuaweiProfileInfo {
  unionID: string;
  openID: string;
  nickName: string;
  avatarUri: string;
  email: string;
}

export class HuaweiAccountService {
  static async login(context: common.Context): Promise<HuaweiAccountSession> {
    const loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
    loginRequest.forceLogin = true;
    loginRequest.state = util.generateRandomUUID();

    const controller = new authentication.AuthenticationController(context);
    const response = await controller.executeRequest(loginRequest) as authentication.LoginWithHuaweiIDResponse;
    if (response.state && response.state !== loginRequest.state) {
      throw new Error('Huawei account login state mismatch');
    }

    const credential = response.data;
    const authorizationCode = credential?.authorizationCode ?? '';
    const idToken = (credential as object as Record<string, string | undefined>)?.idToken ?? '';
    const profile = await HuaweiAccountService.authorizeProfile(context, true);

    return {
      userId: HuaweiAccountService.resolveLocalUserId(idToken, authorizationCode),
      unionID: profile.unionID || credential?.unionID || '',
      openID: profile.openID || credential?.openID || '',
      nickName: profile.nickName,
      avatarUri: profile.avatarUri,
      email: profile.email,
      authorizationCode,
      idToken,
      state: response.state ?? ''
    };
  }

  static async silentLogin(context: common.Context): Promise<HuaweiAccountSession | null> {
    const loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
    loginRequest.forceLogin = false;
    loginRequest.state = util.generateRandomUUID();

    try {
      const controller = new authentication.AuthenticationController(context);
      const response = await controller.executeRequest(loginRequest) as authentication.LoginWithHuaweiIDResponse;
      if (response.state && response.state !== loginRequest.state) {
        return null;
      }
      const credential = response.data;
      const authorizationCode = credential?.authorizationCode ?? '';
      const idToken = (credential as object as Record<string, string | undefined>)?.idToken ?? '';
      const profile = await HuaweiAccountService.authorizeProfile(context, false);
      return {
        userId: HuaweiAccountService.resolveLocalUserId(idToken, authorizationCode),
        unionID: profile.unionID || credential?.unionID || '',
        openID: profile.openID || credential?.openID || '',
        nickName: profile.nickName,
        avatarUri: profile.avatarUri,
        email: profile.email,
        authorizationCode,
        idToken,
        state: response.state ?? ''
      };
    } catch (error) {
      const err = error as BusinessError;
      console.info(`[Account] silent login skipped, code=${err.code}, message=${err.message}`);
      return null;
    }
  }

  private static async authorizeProfile(context: common.Context, forceAuthorization: boolean): Promise<HuaweiProfileInfo> {
    try {
      const request = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
      request.forceAuthorization = forceAuthorization;
      request.scopes = ['profile'];
      request.state = util.generateRandomUUID();
      const controller = new authentication.AuthenticationController(context);
      const response = await controller.executeRequest(request) as authentication.AuthorizationWithHuaweiIDResponse;
      if (response.state && response.state !== request.state) {
        return HuaweiAccountService.emptyProfile();
      }
      const credential = response.data;
      return {
        unionID: credential?.unionID ?? '',
        openID: credential?.openID ?? '',
        nickName: credential?.nickName ?? '',
        avatarUri: credential?.avatarUri ?? '',
        email: credential?.email ?? ''
      };
    } catch (error) {
      const err = error as BusinessError;
      console.info(`[Account] profile authorization skipped, code=${err.code}, message=${err.message}`);
      return HuaweiAccountService.emptyProfile();
    }
  }

  private static emptyProfile(): HuaweiProfileInfo {
    return {
      unionID: '',
      openID: '',
      nickName: '',
      avatarUri: '',
      email: ''
    };
  }

  private static resolveLocalUserId(idToken: string, authorizationCode: string): string {
    const source = idToken || authorizationCode || 'anonymous';
    let hash = 0;
    for (let i = 0; i < source.length; i++) {
      hash = ((hash << 5) - hash) + source.charCodeAt(i);
      hash = hash & hash;
    }
    return `huawei_${Math.abs(hash)}`;
  }
}

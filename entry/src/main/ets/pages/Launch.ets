import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import Logger from '../common/utils/Logger';
import CommonConstants from '../common/constants/CommonConstants';
import RdbUtils from '../common/rdbUtils/RdbUtils';

@Entry
@Component
struct LauncherPage {
  private context?: common.UIAbilityContext;

  onPageShow() {
    this.context = getContext(this) as common.UIAbilityContext;
    this.goToHome();
  }

  async goToHome() {
    const context = getContext(this) as common.UIAbilityContext;
    const savedAuth = await RdbUtils.loadKousouAuth(context);
    const targetUrl = savedAuth ? CommonConstants.INDEX_PAGE_URL : CommonConstants.LOGIN_PAGE_URL;
    if (savedAuth) {
      router.replaceUrl({ url: targetUrl }).catch((error: Error) => {
        Logger.error(CommonConstants.LAUNCHER_PAGE_TAG, 'LauncherPage replaceUrl error ' + JSON.stringify(error));
      });
      return;
    }
    router.replaceUrl({
      url: targetUrl,
      params: CommonConstants.loginGateParams()
    }).catch((error: Error) => {
      Logger.error(CommonConstants.LAUNCHER_PAGE_TAG, 'LauncherPage replaceUrl error ' + JSON.stringify(error));
    });
  }

  build() {
    Column() {
      Image($r('app.media.layered_image'))
        .width(92)
        .height(92)
        .margin({ bottom: 18 })
      Text('抠搜记账')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111')
      Text('本地记账与端侧识别')
        .fontSize(14)
        .fontColor('#7d8985')
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#f9faf5')
  }
}

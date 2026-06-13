import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import CommonConstants from '../common/constants/CommonConstants';

@Entry
@Component
struct Privacy {
  private controller: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Row() {
        Button('‹')
          .width(42)
          .height(36)
          .backgroundColor('#edf0ec')
          .fontColor('#1f2f2b')
          .fontSize(22)
          .onClick(() => {
            router.back();
          })
        Text('隐私政策')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Button('刷新')
          .width(58)
          .height(36)
          .backgroundColor('#e8f6f1')
          .fontColor('#2f7468')
          .fontSize(14)
          .onClick(() => {
            this.controller.refresh();
          })
      }
      .width('100%')
      .padding({ left: 22, right: 22, top: 12, bottom: 12 })
      .backgroundColor('#f9faf5')

      Web({ src: CommonConstants.PRIVACY_DOCUMENT_URL, controller: this.controller })
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#fff')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f9faf5')
  }
}

import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

class loginParams {
  account: String = ''
  passwd: String = ''
  serverIP: String = ''
  serverPort: String = ''
}

@Entry
@Component
struct NasCab {
  @State params: loginParams = router.getParams() as loginParams;
  @State account: String = this.params.account;
  @State passwd: String = this.params.passwd;
  @State serverIP: String = this.params.serverIP;
  @State serverPort: String = this.params.serverPort;
  controller: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Web({ src: this.serverIP + ':' + this.serverPort + '/#/login', controller: this.controller })
        .domStorageAccess(true)
    }
  }
}
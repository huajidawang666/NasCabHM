import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';
import KVStoreService from '../services/KVStoreService'
import { distributedKVStore } from '@kit.ArkData';

export interface ServerItem {
  id: String
  serverIP: String
  serverPort: Number
  serverName: String
  account: String
  passwd: String
}

function checkIPAvailable(serverIP: String, serverPort: Number) : boolean {
  return serverIP == "" || (serverPort >= 0 && serverPort <= 65535)
}

async function checkIsNasCabServer(serverIP: String, serverPort: Number) : Promise<boolean> {
  const session = rcp.createSession();
  let valid = false;
  await session.post("http://"+serverIP+":"+serverPort+"/api/usersApi/checkIsNasServer", "").then((response) => {
    console.info(`Response succeeded:`+response.toString());
    if(response.toString()?.match("NasServer") != null) valid = true;
  }).catch((err: BusinessError) => {
    console.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
  });
  return valid;
}

@Entry
@Component
struct Index {
  @State title: ResourceStr = $r('app.string.title');
  @State account: String = '';
  @State passwd: String = '';
  @State serverName: String = 'MyNasCabServer';
  @State serverIP: String = '';
  @State serverPort: Number = 0;

  build() {
    Column() {
      Text(this.title)
        .id('Title')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .height('20%')
        .margin({bottom: 20})
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
      TextInput({placeholder: '服务器名称(可选)'})
        .type(InputType.Normal)
        .width('80%')
        .placeholderColor(0x808080)
        .margin({bottom: 20})
        .onChange((value: String) => {
          this.serverName = value;
        })
      TextInput({placeholder: '账号'})
        .type(InputType.Normal)
        .width('80%')
        .placeholderColor(0x808080)
        .margin({bottom: 20})
        .onChange((value: String) => {
          this.account = value;
        })
      TextInput({placeholder: '密码'})
        .type(InputType.Password)
        .width('80%')
        .placeholderColor(0x808080)
        .margin({bottom: 20})
        .onChange((value: String) => {
          this.passwd = value;
        })
      TextInput({placeholder: '目标服务器地址'})
        .type(InputType.Normal)
        .width('80%')
        .placeholderColor(0x808080)
        .margin({bottom: 20})
        .onChange((value: String) => {
          this.serverIP = value;
        })
      TextInput({placeholder: '目标服务器端口'})
        .type(InputType.Number)
        .width('80%')
        .placeholderColor(0x808080)
        .margin({bottom: 20})
        .onChange((value: String) => {
          this.serverPort = Number(value);
        })
      Button('登录')
        .width('50%')
        .onClick(async () => {
          console.info("Trying logging in using account: " + this.account
          + "with specified passwd. Target server:" + this.serverIP
          + ":" + this.serverPort);

          if (!checkIPAvailable(this.serverIP, this.serverPort)) console.error("Invalid IP Address");
          else {
            console.log("valid IP Address:"+this.serverIP+":"+this.serverPort);
            let isNasCabServer = await checkIsNasCabServer(this.serverIP, this.serverPort);
            if (!isNasCabServer) console.error("Not a NasCab Server");
            else {
              const newServer : ServerItem = {
                id: Date.now().toString(),
                serverIP: this.serverIP,
                serverPort: this.serverPort,
                serverName: this.serverName,
                account: this.account,
                passwd: this.passwd,
              }

              /*
               * Server List Storage Function
               * Read -> Modify -> Write
               * */

              let kvStore = KVStoreService.getInstance().getKVStore();
              kvStore?.get('NasCabServerList', (err, value) => {
                if (err && err.code != 15100004) {
                  console.error(`Failed to get server. Code is ${err.code}, message is ${err.message}, ${err.stack}`);
                } else {
                  console.debug('Server list retrieved successfully:', value);
                  let serverList : ServerItem[] = [];

                  /*
                   * Having no idea what the F**K happened there....
                   * Possible Cause: On first installation, DataBase won't be initialized.
                   * */

                  if (!err) {
                    serverList = JSON.parse(value as string) as ServerItem[];
                  }
                  console.debug('Current server list:', JSON.stringify(serverList));
                  // Add newServer into serverList here...
                  serverList.push(newServer);

                  kvStore?.put('NasCabServerList', JSON.stringify(serverList))
                    .then(() => {
                      console.info('服务器已保存:', JSON.stringify(serverList));
                    })
                    .catch((err: BusinessError) => {
                      console.error(`Failed to save server. Code is ${err.code}, message is ${err.message}`);
                    });
                  /*
                   * Page Redirect
                   * */
                  this.getUIContext().getRouter().pushUrl({
                    url: 'pages/ServerList',
                  })
                }
              })
            }
          }
        })
    }
    .height('100%')
    .width('100%')
  }
}
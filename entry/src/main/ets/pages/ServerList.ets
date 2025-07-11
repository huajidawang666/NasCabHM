import KVStoreService from '../services/KVStoreService'

export interface ServerItem {
  id: String
  serverIP: String
  serverPort: Number
  serverName: String
  account: String
  passwd: String
}

@Entry
@Component
struct ServerList {
  @State title: ResourceStr = $r('app.string.title');
  @State ListLanes: LengthConstrain = { minLength: 240, maxLength: 360 };
  @State serverList : ServerItem[] = [];
  //
  // aboutToAppear(): void {
  //   let kvStore = KVStoreService.getInstance().getKVStore();
  //   if (!kvStore) {
  //     console.error('KVStore is not initialized');
  //     return;
  //   }
  //
  //   kvStore.get('NasCabServerList', (err, value) => {
  //     if (err) {
  //       console.error(`Failed to get NasCabServerList: Code is ${err.code}, message is ${JSON.stringify(err)}`);
  //       return;
  //     }
  //
  //     try {
  //       let list = JSON.parse(value as string) as ServerItem[];
  //       this.serverList = list;
  //       console.info("读取服务器成功:", list);
  //     } catch (error) {
  //       console.error("解析服务器列表失败:", error);
  //     }
  //   })
  // }

  build() {
    Column() {
      Text(this.title)
        .id('Main_Title')
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .height('20%')
        .margin({bottom: 20})
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
      List() {
        ForEach(this.serverList, (server : ServerItem, index) => {
          ListItem(){
            Column() {
              // Text(server.serverName.toString()).fontSize(18).fontWeight(FontWeight.Medium)
              Text(server.serverIP.toString()).fontSize(14).fontColor(Color.Grey)
            }
            .padding(12)
            .backgroundColor('#F5F5F5')
            .borderRadius(12)
            .margin({ bottom: 8, left: 12, right: 12 })
          }
        })
      }
        .width('90%')
        .height(550)
        .listDirection(Axis.Vertical)
        .lanes(this.ListLanes)
        .alignListItem(ListItemAlign.Center)

      Button('󰀵')
        .position({right: 50, bottom: 50})
        .type(ButtonType.Circle)
        .onClick(() => {
          this.getUIContext().getRouter().pushUrl({
            url: 'pages/AddServer',
          })
        })

    }
    .height('100%')
    .width('100%')
  }
}
import {distributedKVStore} from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit'

class KVStoreService {
  private static instance: KVStoreService
  private kvManager: distributedKVStore.KVManager | undefined
  private kvStore: distributedKVStore.SingleKVStore | undefined

  private constructor() {}

  public static getInstance(): KVStoreService {
    if (!KVStoreService.instance) {
      KVStoreService.instance = new KVStoreService()
    }
    return KVStoreService.instance
  }

  // 初始化（在应用 onCreate 时调用一次）
  public init(config: distributedKVStore.KVManagerConfig): void {
    this.kvManager = distributedKVStore.createKVManager(config);

    this.kvManager.getKVStore(
      'NasCabServerList',
      {
        encrypt: false,
        createIfMissing: true,
        autoSync: true,
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
        securityLevel: distributedKVStore.SecurityLevel.S2,
      }, (err: BusinessError, store: distributedKVStore.SingleKVStore) => {
        if (!err){
          console.log('Getting KvStore...');
          this.kvStore = store;
          console.log('Get KvStore successfully');
        } else {
          console.error(err.message);
        }
      }
    )
  }

  // 获取存储实例
  public getKVStore(): distributedKVStore.SingleKVStore | undefined {
    return this.kvStore;
  }
}

export default KVStoreService
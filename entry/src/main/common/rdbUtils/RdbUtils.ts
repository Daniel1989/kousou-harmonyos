import relationalStore from '@ohos.data.relationalStore';

interface Tag {
  amount: string
  tag: string,
  type: string,
  createAt: string,
}

export class MyTag {
  amount: string;
  tag: string;
  type: string;
  createAt: string;

  constructor(tag: string, type: string, amount: string, createAt: string) {
    this.amount =  amount;
    this.tag = tag;
    this.type = type;
    this.createAt = createAt;
  }

  toString() {
    return this.amount + this.tag + this.type + this.createAt
  }
}

export default class RdbUtils {
  private static rdbStore: relationalStore.RdbStore;

  static setStore(store: relationalStore.RdbStore) {
    RdbUtils.rdbStore = store;
  }

  static getStore(): relationalStore.RdbStore {
    return RdbUtils.rdbStore;
  }

  static executeSql(sql: string): Promise<void> {
    return RdbUtils.getStore().executeSql(sql);
  }

  static insert(tableName: string, data:any): Promise<number> {
    return RdbUtils.getStore().insert(tableName, data);
  }

  static queryAll(tableName: string): Promise<Array<MyTag>> {
    let predicates = new relationalStore.RdbPredicates(tableName);
    return new Promise<Array<MyTag>>((resolve, reject) => {
      RdbUtils.getStore().query(predicates).then((result)=> {
        let recordList: MyTag[]= new Array<MyTag>();
        while (result.goToNextRow()) {
          const abc = result.getValue(1);
          recordList.push( new MyTag(abc as string,result.getValue(2) as string,result.getValue(3) as string,result.getValue(4) as string))
        }
        resolve(recordList)
      }).catch((error)=> {
        reject(error)
      })
    })
  }
}
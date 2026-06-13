import RdbUtils, { MyTag } from "../../common/rdbUtils/RdbUtils";
import { INIT_TAG, Tag } from "./Money";
import { Recent } from "./Recent";

interface MyRecord {
  createAt: string,
  amount: string,
  category: string,
  note: string,
  tagId:number,
}

export interface  NewRecordItem {
  tagId: number,
  amount: string,
  category: string,
  icon: string,
  name: string,
  createAt: string,
}

type FormatRecordObject =  Record<string, Array<NewRecordItem>>

export interface FormatRecordList {
  date: string,
  list: Array<NewRecordItem>
}

interface MatchTag {icon: string, name: string}

@Component
export struct Home {
  @State showHistory: boolean = false;
  @State visibleRecordCount: number = 12;
  @State isLoadingMore: boolean = false;

  @State todayIncome: number = 0;
  @State todayCost: number = 0;

  @State recordList: FormatRecordList[] = [];

  @Watch('handleMenuChange') @Link currentMenu: string;
  @Link userId: string;
  @Watch('handleSyncChange') @Link syncRevision: number;
  @Prop ocrLoading: boolean = false;
  onRecognizeImage: () => void = () => {};

  aboutToAppear() {
    if(RdbUtils.getStore()) {
      this.queryData();
    } else {
      const checker = setInterval(()=> {
        if(RdbUtils.getStore()) {
          this.queryData();
          clearInterval(checker)
        }
      },100)
    }
  }

  handleMenuChange() {
    if (this.currentMenu === 'home' && RdbUtils.getStore()) {
      this.queryData();
    }
  }

  handleSyncChange() {
    if (this.currentMenu === 'home' && RdbUtils.getStore()) {
      this.queryData();
    }
  }

  currentLocalDateKeys(): string[] {
    const offsets = [0, 8, 16];
    const keys: string[] = [];
    offsets.forEach((offset: number) => {
      const key = new Date(Date.now() + offset * 60 * 60 * 1000).toISOString().slice(0, 10);
      if (!keys.includes(key)) {
        keys.push(key);
      }
    });
    return keys;
  }


  queryData = () => {
    const queryTasks: Promise<Array<MyTag>>[] = this.userId === 'local'
      ? [RdbUtils.queryAll('ACCOUNT', this.userId)]
      : [RdbUtils.queryAll('ACCOUNT', this.userId), RdbUtils.queryAll('ACCOUNT', 'local')];
    Promise.all(queryTasks).then((queryResults)=> {
      const res = queryResults.reduce((all, item) => all.concat(item), []);
      const todayKeys = this.currentLocalDateKeys();

      const homeRecordList: MyRecord[] = [];
      res.forEach((item)=> {
        console.log('RdbInfo', item.toString())
        const target = INIT_TAG.find((tag)=>tag.name === item.tag )
        if (!target) {
          console.warn(`[RdbInfo] skip unknown tag ${item.tag}`);
          return;
        }
        homeRecordList.push({
          createAt: item.createAt,
          amount: item.amount,
          category: item.type,
          note: "",
          tagId: target.id
        })
      })

      const todayRecordList = homeRecordList.reduce((arr, item) => {
        if(todayKeys.some((key: string) => item.createAt.includes(key))){
          arr.push(item)
        }
        return arr
      }, [] as Array<MyRecord>)

      const todayTotalIncome = (todayRecordList).reduce((total, item) => {
        if(item.category === 'income') {
          return total + Number(item.amount)
        }
        return total
      }, 0)

      const todayTotalCost = (todayRecordList).reduce((total, item) => {
        if(item.category === 'cost') {
          return total + Number(item.amount)
        }
        return total
      }, 0)

      this.todayIncome = todayTotalIncome;
      this.todayCost = todayTotalCost;

      let formatObj: FormatRecordObject = {}
      homeRecordList.forEach((item) => {
        const tagId = item.tagId;
        const category = item.category;
        const amount = item.amount;
        const createAt = item.createAt;

        let matchedTag: MatchTag = { icon: '', name: '' }
        INIT_TAG.forEach((tag: Tag) => {
          const icon = tag.icon;
          const name = tag.name;
          const id = tag.id;
          if(tagId === id) {
            matchedTag = {icon, name}
          }
        })
        const date = createAt.slice(0, 10);
        const newItem: NewRecordItem  = {
          tagId,
          category,
          amount,
          icon: matchedTag.icon,
          name: matchedTag.name,
          createAt: createAt
        }
        if (formatObj[date]) {
          formatObj[date].unshift(newItem)
        } else {
          formatObj[date] = [newItem]
        }
      })
      let formatList: FormatRecordList[] = []
      Object.keys(formatObj).forEach((key)=> {
        formatList.push({date: key, list: formatObj[key]})
      })
      this.recordList = formatList;
    }).catch((error: Error) => {
      console.error(`[RdbInfo] query home data failed: ${error.message}`);
    })
  }

  calcRotate = () => {
    if(this.showHistory) {
      return 180;
    } else {
      return 0;
    }
  }

  sortedRecordList(): FormatRecordList[] {
    return this.recordList.slice().sort((a: FormatRecordList, b: FormatRecordList) => new Date(b.date).getTime() - new Date(a.date).getTime());
  }

  totalRecordCount(): number {
    return this.recordList.reduce((total: number, item: FormatRecordList) => total + item.list.length, 0);
  }

  hasMoreRecords(): boolean {
    return this.visibleRecordCount < this.totalRecordCount();
  }

  visibleRecordList(): FormatRecordList[] {
    let remain = this.visibleRecordCount;
    const result: FormatRecordList[] = [];
    this.sortedRecordList().forEach((day: FormatRecordList) => {
      if (remain <= 0) {
        return;
      }
      const list = day.list.slice(0, remain);
      if (list.length > 0) {
        result.push({ date: day.date, list });
        remain -= list.length;
      }
    });
    return result;
  }

  loadMoreRecords() {
    if (this.isLoadingMore || !this.hasMoreRecords()) {
      return;
    }
    this.isLoadingMore = true;
    this.visibleRecordCount += 12;
    this.isLoadingMore = false;
  }

  handleReachEnd() {
    if (!this.showHistory) {
      return;
    }
    this.loadMoreRecords();
  }

  toggleHistory() {
    this.showHistory = !this.showHistory;
    if (!this.showHistory) {
      this.visibleRecordCount = 12;
    }
  }

  build() {
    Scroll(){
      Column() {
        Column() {
          Column() {
            Text('今日支出')
              .fontColor('#9ecdc1')
              .fontSize(14)
            Text('¥'+ this.todayCost)
              .fontColor('#9ecdc1')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .margin({top: 4, bottom: 4})
              .lineHeight(36)
            Text('收入¥'+this.todayIncome)
              .fontColor('#acacac')
              .fontSize(14)
          }
          .margin({top: 20, bottom: 18})

          Text('记一笔')
            .margin({ top: 12, bottom: 8 })
            .padding({ top: 8, bottom: 8, left: 32, right: 32 })
            .backgroundColor('#a1e0cf')
            .border({ width: 2, color: '#9acdbc', style: BorderStyle.Solid, radius: 8 })
            .fontColor('#333')
            .fontSize(14)
            .onClick(() => {
              this.currentMenu = 'money';
            })

          Text(this.ocrLoading ? '识别中...' : '识别图片')
            .fontSize(14)
            .fontColor('#2f7468')
            .decoration({ type: TextDecorationType.Underline, color: '#2f7468' })
            .margin({ bottom: 12 })
            .opacity(this.ocrLoading ? 0.6 : 1)
            .onClick(() => {
              if (!this.ocrLoading) {
                this.onRecognizeImage();
              }
            })

          Row() {
            Text(this.showHistory ? '收起账单' : '展示最近账单')
              .fontColor('#66736f')
              .fontSize(16)
            Image($rawfile('icons/up.svg'))
              .width(28)
              .height(28)
              .fillColor('#66736f')
              .rotate({angle: this.calcRotate()})
              .animation({
                duration: 200,
                curve: Curve.EaseOut,
                iterations: 1,
                playMode: PlayMode.Normal
              })
          }
          .margin({ bottom: this.showHistory ? 4 : 16 })
          .onClick(() => {
            this.toggleHistory();
          })
        }
        .justifyContent(FlexAlign.Start)
        .width('100%')

        if(this.showHistory) {
          Column() {
            ForEach(this.visibleRecordList(), (item: FormatRecordList) => {
              Recent({
                item: item
              })
            }, (item: FormatRecordList) => item.date)
            if (this.hasMoreRecords()) {
              Text('上滑加载更多')
                .fontSize(12)
                .fontColor('#8d9996')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding({ top: 8, bottom: 12 })
            } else if (this.totalRecordCount() > 0) {
              Text('没有更多了')
                .fontSize(12)
                .fontColor('#8d9996')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding({ top: 8, bottom: 12 })
            } else {
              Text('暂无账单记录')
                .fontSize(13)
                .fontColor('#8d9996')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding({ top: 8, bottom: 12 })
            }
          }
          .width('100%')
        }
      }
      .width('100%')
    }
    .scrollBar(BarState.Off)
    .scrollBarColor(Color.Transparent)
    .scrollBarWidth(0)
    .onReachEnd(() => {
      this.handleReachEnd();
    })
    .width('100%')
    .height('100%')
  }
}

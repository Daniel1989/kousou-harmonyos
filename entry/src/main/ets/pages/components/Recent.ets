import { FormatRecordList, NewRecordItem } from "./Home";

@Component
export struct Recent {
    @Prop item: FormatRecordList

    computeCost = () => {
      return this.item.list.reduce((total, item) => {
        if(item.category === 'cost') {
          return total + Number(item.amount)
        } else {
          return total;
        }
      }, 0)
    }

  computeIncome = () => {
    return this.item.list.reduce((total, item) => {
      if(item.category === 'income') {
        return total + Number(item.amount)
      } else {
        return total;
      }
    }, 0)
  }

  computeMoney = (type: string, amount: string ) => {
      if(type === 'income') {
        return '￥' + amount
      } else {
        return '-￥' + amount
      }
  }

  getIcon = (name: string) => {
      return 'icons/tags/'+name+'.svg'
  }

  getList = () => {
      return this.item.list.map((_, index)=> index);
  }

    build() {
      Column() {
        Row() {
          Text(this.item.date)
            .fontSize(14)
            .fontColor('#9ecdc1')
          Row() {
            Text('支出￥' + this.computeCost())
              .fontSize(14)
              .fontColor('#adadad')
            Text('收入￥' + this.computeIncome())
              .fontSize(14)
              .fontColor('#adadad')
              .margin({left: 8})
          }
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .margin({bottom: 10})

        ForEach(this.getList(), (record: number) => {
          Row() {
            Row() {
              Image($rawfile(this.getIcon(this.item.list[record].icon)))
                .width(30)
                .height(30)
                .margin({right: 6})
              Text(this.item.list[record].name)
                .fontSize(16)
                .fontColor('#333')
            }
            Column() {
              Text(this.computeMoney(this.item.list[record].category, this.item.list[record].amount))
                .fontSize(16)
                .fontColor('#333')
                .fontWeight(FontWeight.Bold)
                .margin({bottom: 2})
                .textAlign(TextAlign.End)
                .alignSelf(ItemAlign.End)
              Text(this.item.list[record].createAt.slice(11, 16))
                .fontSize(14)
                .fontColor('#adadad')
                .textAlign(TextAlign.End)
                .alignSelf(ItemAlign.End)
            }
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')
          .backgroundColor('#fafbf6')
          .padding(8)
          .border({radius: 8})
          .margin({bottom: 10})
        }, (item: string) => item)


      }
      .margin(16)
    }
}
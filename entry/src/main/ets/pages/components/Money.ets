export interface Tag {
  id: number,
  name: string,
  icon: string,
  category: string,
}

export const INIT_TAG: Tag[] = [
  { id: 0, name: '房租', icon: 'fangzu', category: 'cost' },
  { id: 1, name: '水电', icon: 'shuidian', category: 'cost' },
  { id: 2, name: '居家', icon: 'shop', category: 'cost' },
  { id: 3, name: '交通', icon: 'train', category: 'cost' },
  { id: 4, name: '学习', icon: 'book', category: 'cost' },
  { id: 5, name: '日用', icon: 'riyong', category: 'cost' },
  { id: 6, name: '餐饮', icon: 'canyin', category: 'cost' },
  { id: 7, name: '购物', icon: 'shopping', category: 'cost' },
  { id: 8, name: '娱乐', icon: 'youxi', category: 'cost' },
  { id: 9, name: '旅游', icon: 'lvyou', category: 'cost' },
  { id: 10, name: '宠物', icon: 'chongwu', category: 'cost' },
  { id: 11, name: '工资', icon: 'gongji', category: 'income' },
  { id: 12, name: '报销', icon: 'baoxiao', category: 'income' },
  { id: 13, name: '补助', icon: 'buzhu', category: 'income' },
  { id: 14, name: '红包', icon: 'hongbao', category: 'income' },
  { id: 15, name: '分红', icon: 'fenhong', category: 'income' },
  { id: 16, name: '奖金', icon: 'jiangjin', category: 'income' },
  { id: 17, name: '借款', icon: 'jiekuan', category: 'income' },
]

@Component
export struct Money {
  @State moneyType: string = 'cost';
  @State selectedTag: Tag | null = null;

  updateTag?: (data: Tag) => void;

  @State tagList: Tag[] = INIT_TAG;
  getSelectedColor = (currentType: string) => {
    if(currentType !== this.moneyType) {
      return '#e8ecef'
    } else {
      return '#fff'
    }
  }

  getCurrentTypeTag = () => {
    return this.tagList.filter((item)=> {
      return item.category == this.moneyType
    })
  }

  getCurrentTypeTagIndex = () => {
    return this.tagList.filter((item)=> {
      return item.category == this.moneyType
    }).map((_, index)=> {
      return index;
    })
  }

  getIconStr = (name: string) => {
    return 'icons/tags/'+name+'.svg';
}

  getSelectedTagColor = (target: Tag) => {
    if(this.selectedTag) {
      if(target.id === this.selectedTag.id) {
        return '#95c8be'
      }
    }
    return 'transparent'
  }

  getSelectedTagBgColor = (target: Tag) => {
    if(this.selectedTag) {
      if(target.id === this.selectedTag.id) {
        return '#a0ded1'
      }
    }
    return 'transparent'


  }

  build() {
    Column() {
      Row() {
        Text("记一笔")
          .fontColor('#010101')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({left: 10})
        Row() {
          Text("收入")
            .padding({top: 3, bottom: 3, left: 8, right: 8})
            .border({radius: 4})
            .backgroundColor(this.getSelectedColor('income'))
            .fontSize(14)
            .onClick(()=> {
              this.moneyType = 'income'
            })
          Text("支出")
            .padding({top: 3, bottom: 3, left: 8, right: 8})
            .border({radius: 4})
            .backgroundColor(this.getSelectedColor('cost'))
            .fontSize(14)
            .onClick(()=> {
              this.moneyType = 'cost'
            })
        }
        .padding(2)
        .border({radius: 4})
        .backgroundColor("#e8ecef")
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .padding({top: 10, bottom: 10, right: 20, left: 20})
      Flex({justifyContent: FlexAlign.Start, direction: FlexDirection.Row, wrap: FlexWrap.Wrap}) {
        ForEach(this.getCurrentTypeTagIndex(), (item: string) => {
            Column(){
              Image($rawfile(this.getIconStr(this.getCurrentTypeTag()[parseInt(item)].icon)))
                .width(40)
                .height(40)
              Text(this.getCurrentTypeTag()[parseInt(item)].name)
                .fontSize(14)
            }
              .justifyContent(FlexAlign.Center)
              .width('calc(20% - 8px)')
              .margin({top: 4, bottom: 0, left: 4, right: 4})
              .padding({top: 4, bottom: 4, left: 8, right: 8})
              .border({radius: 8, width: 2, color: this.getSelectedTagColor(this.getCurrentTypeTag()[parseInt(item)]), style: BorderStyle.Solid})
              .backgroundColor(this.getSelectedTagBgColor(this.getCurrentTypeTag()[parseInt(item)]))
          .onClick(() => {
            const target = this.getCurrentTypeTag()[parseInt(item)];
            this.selectedTag = target;
            if(this.updateTag) {
              this.updateTag(target)
            }
          })
        }, (item: string) => item)
      }
      .padding({top: 4, bottom: 12, left: 16, right: 16})
      .backgroundColor('#f9faf5')
      .constraintSize({minHeight: '30%'})
    }
    .width('100%')
    .height('100%')
  }
}
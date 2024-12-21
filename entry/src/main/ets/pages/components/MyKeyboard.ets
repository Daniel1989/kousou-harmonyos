import { promptAction } from '@kit.ArkUI';

@CustomDialog
struct CustomDialogExample {
  controller: CustomDialogController = new CustomDialogController({
    builder: CustomDialogExample({}),
  })

  build() {
    Column() {
      Text('我是内容')
        .fontSize(20)
        .margin({ top: 10, bottom: 10 })
    }
  }
}

@Component
export struct MyKeyboard {

  @State idx: string[] = [
    '',
    '1', '2', '3', '删除',
    '4', '5', '6', '+',
    '7', '8', '9', '-',
    '.', '0', '清零', '完成',
  ];

  @State totalValue: string = '0';

  saveRecord?: (amount: string) => boolean;

  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialogExample(),
  })

  transArray = (strArr: Array<string>) => {
    strArr.forEach((str, index) => {
      if(str === '') {
        strArr[index] = '0'
      }
    })

    return strArr.reduce((arr: Array<string>, val) => {
      // 数组最后一个是符号
      if(/(\+|-)/.test(val) || arr.length === 0){
        arr.push(val)
      } else {
        arr[arr.length-1] = arr[arr.length-1] + val
      }
      return arr
    }, [])
  }

  updateOutput: (text: string, output: string) => string = (text: string, output: string) => {
        if(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].includes(text)) {
          if(output === '0') {
            return text;
          } else if(/([+-])0$/.test(output)) {
            return output.slice(0, -1) + text
          } else {
            return output + text;
          }
        } else if(text === '+') {
          if(/\.$/.test(output)) {
          return output + '0' + text;
        } else if(/\D$/.test(output)){
          return output.slice(0, -1) + text
        } else if(output === '0') {
          return output
        } else {
          return output + text
        }
        } else if(text === '-') {
           if(/\.$/.test(output)) {
          return output + '0' + text;
        } else if(/\D$/.test(output)){
          return output.slice(0, -1) + text
        } else if(output === '0') {
          return '-'
        } else {
          return output + text
        }
        } else if(text === '.') {
          if(/(\.\d*|\D)$/.test(output)) {
          return output;
        } else {
          return output + '.';
        }
        } else if(text === '删除') {
          if(output.length > 1) {
          return output.slice(0, -1) || '0';
        } else {
          return '0'
        }
        } else if(text === '清零') {
          return '0';
        } else if(text === '完成') {
          let strArr = output.split(/(\+|-)/)
          let newStrArr = this.transArray(strArr)
          let total = newStrArr.reduce((sum, cur)=> {
            return sum + parseFloat((cur))
          }, 0.0)
          return total.toString()
        } else {
          return '0'
        }

  }

  layoutOptions: GridLayoutOptions = {
    regularSize: [1, 1],
    onGetRectByIndex: (index: number) => {
      if (index == 0) { // key1是“0”按键对应的index
        return [0, 0, 1, 4]
      } else {
        return [(index - 1) / 4 + 1,index % 4 - 1,1,1]
      }
    }
  }

  getTextAlign = (index: number) => {
    if(index === 0) {
      return TextAlign.End
    } else {
      return TextAlign.Center
    }
  }

  getTextPadding = (index: number) => {
    if(index === 0) {
      return 16
    } else {
      return 0
    }
  }

  getTextBg = (index: number) => {
    if(index === 16) {
      return '#f1c21a'
    } else {
      return '#fff'
    }
  }

  getTextContent = (index: number, item: string) => {
    if(index === 0) {
      return this.totalValue
    } else if(index === 16){
      if(this.totalValue === '' || /^-?\d+\.?\d*$/.test(this.totalValue)) {
        return '完成'
      } else {
        return '='
      }
    } else {
      return item
    }
  }

  @Styles calcKeyPressStyle(){
    .width('100%')
    .height(40)
    .border({width: 2, color: '#000', style: BorderStyle.Solid, radius: 8})
    .margin({top: 8})
  }

  build() {
    Grid(undefined, this.layoutOptions) {
      ForEach(this.idx, (item: string, index: number) => {
        GridItem() {
          Text(this.getTextContent(index, item))
            .calcKeyPressStyle()
            .fontSize(24)
            .backgroundColor(this.getTextBg(index))
            .textAlign(this.getTextAlign(index))
            .padding({ right: this.getTextPadding(index) })
        }.onClick(() => {
          const text = item;
          if(text === '') {
            console.log("do nothing")
          } else if(text === '完成' && /^-?\d+\.?\d*$/.test(this.totalValue)) {
            // TODO
            // 1. 存到localstorage
            // 2. message提醒
            // this.dialogController.open()
            if(this.saveRecord) {
              const result = this.saveRecord(this.totalValue);
              if(result) {
                this.totalValue = '0'
              }
            }
          } else {
            const result =  this.updateOutput(text, '' + this.totalValue)
            if(result.length > 20) return
            this.totalValue = result
          }
        })
      }, (item: string) => item)
    }
    .padding(16)
    .backgroundColor('#9bcabf')
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .rowsTemplate('1fr 1fr 1fr 1fr 1fr')
    .columnsGap(16)
  }
}
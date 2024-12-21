1. navigation是用来展示子页面的。所以如果tab的形式，还是需要独立页面的形式
2. 自定义组件，可以类比有状态的container，@Builder函数类比无状态的UI组件
3. 如果涉及到slot，需要BuilderParam
4. 子组件的state可以理解为props通过调用方传入
5. height无明确，是默认其子元素的高度，如果写了100%，会找到祖先的有明确高度的父节点，默认为屏幕剩余未占位的高度
6. 尽量用class，不要用object
7. preview不支持数据库，会报错。用模拟器
8. foreach循环，如果是对象数组，需要加index
9. 类型声明时，如果是动态key，需要使用Record
10. 如果修改代码不生效，需要build-rebuild或者file-invalidate caches

11. p12 生成csr，csr生成cer 这两个是应用无关的，只用来生成证书。生成csr过程中需要设置store password和alias以及对应password，这两个也是和应用无关的。但是在后面设置sign时，必须和生成csr的对上
12. p7b生成时，需要选择证书和应用，证书是上面用的。然后通过选应用绑定在一起


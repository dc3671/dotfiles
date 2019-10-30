// 需要先全局安装相关包
// yarn global add eslint typescript typescript-eslint-parser eslint-plugin-typescript eslint-plugin-react eslint-config-alloy
module.exports = {
    extends: [
        'eslint-config-alloy/typescript-react',
    ],
    globals: {
        // 这里填入你的项目需要的全局变量
        // 这里值为 false 表示这个全局变量不允许被重新赋值，比如：
        //
        // jQuery: false,
        // $: false
    },
    rules: {
        // 这里填入你的项目需要的个性化配置，比如：
        //
        // @fixable 一个缩进必须用两个空格替代
        'indent': [
            'error',
            2,
            {
                SwitchCase: 1,
                flatTernaryExpressions: true,
                'ignoredNodes': ['JSXElement *']
            }
        ],
        'react/jsx-indent-props': [ 'error', 2 ],
        // TypeScript的类型无法正确判定
        'no-unused-vars': 'off'
    }
};

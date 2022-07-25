module.exports = {
    root: true,
    extends: ["airbnb", "airbnb/hooks", "@react-native-community"],
    parser: "@typescript-eslint/parser",
    plugins: ["@typescript-eslint", "react", "prettier"],
    overrides: [
        {
            files: ["*.ts", "*.tsx"],
            rules: {
                "@typescript-eslint/no-shadow": ["error"],
                "no-shadow": "off",
                "no-undef": "off",
                quotes: [2, "double", {avoidEscape: false}],
            },
        },
    ],
    parserOptions: {
        ecmaFeatures: {
            jsx: true,
        },
        ecmaVersion: 2018,
        sourceType: "module",
        project: "./tsconfig.json",
    },
    rules: {
        "import/no-unresolved": 0,
        "react/jsx-filename-extension": [
            1,
            {
                extensions: [".ts", ".tsx"],
            },
        ],
        "prettier/prettier": [
            "error",
            {
                singleQuote: false,
                trailingComma: "all",
                arrowParens: "avoid",
                endOfLine: "auto",
            },
        ],
        "no-use-before-define": "off",
        "@typescript-eslint/no-use-before-define": ["error"],
        "import/extensions": ["error", "never"],
        "react/prop-types": 0,
        "no-shadow": "off",
        "@typescript-eslint/no-shadow": ["error"],
        "react/function-component-definition": [
            2,
            {namedComponents: "arrow-function"},
        ],
    },
    ignorePatterns: [".eslintrc.js"],
};

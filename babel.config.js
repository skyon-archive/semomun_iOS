module.exports = {
    presets: ["module:metro-react-native-babel-preset"],
    plugins: [
        [
            "module-resolver",
            {
                root: ["./src"],
                extensions: [
                    ".ios.js",
                    ".android.js",
                    ".jsx",
                    ".js",
                    ".json",
                    ".ios.ts",
                    ".android.ts",
                    ".ios.tsx",
                    ".android.tsx",
                    ".tsx",
                    ".ts",
                ],
            },
        ],
    ],
};

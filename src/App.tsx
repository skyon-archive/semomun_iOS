import {NavigationContainer} from "@react-navigation/native";
import {RootNavigator} from "navigations";
import React from "react";
import {SafeAreaProvider} from "react-native-safe-area-context";

const App = () => {
    return (
        <SafeAreaProvider>
            <NavigationContainer>
                <RootNavigator />
            </NavigationContainer>
        </SafeAreaProvider>
    );
};

export default App;

/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * Generated with the TypeScript template
 * https://github.com/react-native-community/react-native-template-typescript
 *
 * @format
 */

import SearchTagVC from "../components/native/Home/SearchTagVC";
import HomeVC from "../components/native/Home/HomeVC";
import WarningOfflineStatus from "../components/native/Home/WarningOfflineStatus";
import HomeHeader from "../components/native/Home/HomeHeader";
import React from "react";
import {SafeAreaProvider} from "react-native-safe-area-context";
import {View, Text, Button} from "react-native";


const App = () => {



    return (
        <SafeAreaProvider style={{height: "100%", width: "100%", display:"flex", flexDirection:"column"}}>
            <HomeVC />
            <SearchTagVC/>
            <View style={{height: "100%", width: "100%", display:"flex", alignItems:"center", justifyContent:"center"}}>

            </View>
        </SafeAreaProvider>
    );
};

export default App;

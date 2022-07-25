import {NativeStackScreenProps} from "@react-navigation/native-stack";
import {RootParamList} from "navigations/RootNavigator";
import React from "react";
import {Button, View, NativeModules} from "react-native";
import RNUserDefaults from "rn-user-defaults";

const {RNTCoreUseCase} = NativeModules;

const TestScreen = ({navigation}: NativeStackScreenProps<RootParamList>) => {
    const handleMagic = () => {
        RNUserDefaults.objectForKey("logined").then(r => console.log(r));
        RNTCoreUseCase.fetchUserInfo()
            .then(r => console.log(r))
            .catch(error => console.log(error.description));
    };
    return (
        <View>
            <Button
                title="Magic"
                onPress={() => navigation.navigate("Login")}
            />
            <Button title="Magic2" onPress={handleMagic} />
        </View>
    );
};

export default TestScreen;

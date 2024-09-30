import { View, Text, FlatList } from "react-native";
import { Drawer } from "expo-router/drawer";
import { useNavigation } from "expo-router";
import { Colors } from "../constants/Colors";
import { useColorScheme } from "@/hooks/useColorScheme";
import { createClientId } from "@/modules/tdlib-rn";
// import { hello } from "@/modules/tdlib-rn";
import { useEffect } from "react";
export default function HomePage() {
  const navigation = useNavigation();

  const chats = [
    { id: 1, title: "Chat 1" },
    { id: 2, title: "Chat 2" },
    // Add more chat items
  ];

  useEffect(() => {
    try {
      const clientId = createClientId();
      console.log(clientId);
      // console.log(hello());
    } catch (error) {
      console.error(error);
    }

    // // const clientId = createClientId();
    // // console.log(clientId);
    // console.log("Hello from HomePage");
  }, []);

  return (
    <View style={{ flex: 1 }}>
      <FlatList
        data={chats}
        renderItem={({ item }) => (
          <View
            style={{
              padding: 16,
              borderBottomWidth: 1,
              borderBottomColor: "#ccc",
            }}
          >
            <Text>{item.title}</Text>
          </View>
        )}
        keyExtractor={(item) => item.id.toString()}
      />
    </View>
  );
}

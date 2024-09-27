import { View, Text, FlatList } from "react-native";
import { Drawer } from "expo-router/drawer";
import { useNavigation } from "expo-router";
import { Colors } from "../constants/Colors";
import { useColorScheme } from "@/hooks/useColorScheme";

function HomePage() {
  const navigation = useNavigation();

  const chats = [
    { id: 1, title: "Chat 1" },
    { id: 2, title: "Chat 2" },
    // Add more chat items
  ];

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

export default function HomePageWrapper() {
  const colorScheme = useColorScheme();

  return (
    <Drawer.Screen
      options={{
        headerStyle: {
          backgroundColor: Colors[colorScheme ?? "light"].tabIconSelected,
        },
        headerTintColor: "#fff",
        drawerStyle: {
          backgroundColor: "#f0f0f0",
        },
      }}
    />
  );
}

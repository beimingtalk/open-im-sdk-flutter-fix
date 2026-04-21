import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('unreadCount parsing', () {
    test('ConversationInfo parses numeric variants safely', () {
      expect(ConversationInfo.fromJson({'conversationID': 'c1', 'unreadCount': 3}).unreadCount, 3);
      expect(ConversationInfo.fromJson({'conversationID': 'c1', 'unreadCount': 3.0}).unreadCount, 3);
      expect(ConversationInfo.fromJson({'conversationID': 'c1', 'unreadCount': '4'}).unreadCount, 4);
      expect(ConversationInfo.fromJson({'conversationID': 'c1', 'unreadCount': '5.0'}).unreadCount, 5);
      expect(ConversationInfo.fromJson({'conversationID': 'c1', 'unreadCount': null}).unreadCount, 0);
      expect(ConversationInfo.fromJson({'conversationID': 'c1', 'unreadCount': -2}).unreadCount, 0);
      expect(ConversationInfo.fromJson({'conversationID': 'c1', 'unreadCount': 'bad'}).unreadCount, 0);
    });

    test('GroupHasReadInfo parses numeric variants safely', () {
      final info = GroupHasReadInfo.fromJson({
        'hasReadCount': '7.0',
        'unreadCount': 8.0,
      });

      expect(info.hasReadCount, 7);
      expect(info.unreadCount, 8);
    });
  });
}

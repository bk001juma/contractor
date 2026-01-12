import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkUtils {
  static Future<String> getLocalIpAddress() async {
    if (kIsWeb) {
      return 'localhost';
    }

    try {
      print('🔍 Scanning network interfaces...');

      // List all network interfaces
      final interfaces = await NetworkInterface.list();
      print('📡 Found ${interfaces.length} network interfaces:');

      for (var interface in interfaces) {
        print('   Interface: ${interface.name}');
        for (var addr in interface.addresses) {
          print('     ${addr.type}: ${addr.address}');
        }
      }

      // Prefer WiFi/WLAN interfaces
      for (var interface in interfaces) {
        final name = interface.name.toLowerCase();
        if (name.contains('wifi') ||
            name.contains('wlan') ||
            name.contains('en0')) {
          for (var addr in interface.addresses) {
            if (addr.type == InternetAddressType.IPv4 &&
                !addr.address.startsWith('127.')) {
              print('✅ Selected IP from ${interface.name}: ${addr.address}');
              return addr.address;
            }
          }
        }
      }

      // Fallback: any non-loopback IPv4
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              !addr.address.startsWith('127.')) {
            print('⚠️ Fallback IP from ${interface.name}: ${addr.address}');
            return addr.address;
          }
        }
      }

      print('❌ No suitable IP found, using localhost');
      return 'localhost';
    } catch (e) {
      print('❌ Error getting IP address: $e');
      return 'localhost';
    }
  }

  // Test if server is reachable
  static Future<bool> isServerReachable(String ip, int port) async {
    try {
      print('🔌 Testing connection to $ip:$port...');

      final socket =
          await Socket.connect(
            ip,
            port,
            timeout: Duration(seconds: 5),
          ).catchError((e) {
            print('❌ Socket connection failed: $e');
            return null;
          });

      if (socket != null) {
        socket.destroy();
        print('✅ Server is reachable at $ip:$port');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }

  // Get computer's actual IP for mobile access
  static Future<String> getComputerIpForMobile() async {
    // Common local IP ranges
    final commonRanges = [
      '192.168.', // Home networks
      '10.0.', // Business networks
      '172.16.', // Corporate networks
    ];

    try {
      final interfaces = await NetworkInterface.list();

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              !addr.address.startsWith('127.')) {
            // Check if it's in a common local range
            for (var range in commonRanges) {
              if (addr.address.startsWith(range)) {
                print('🏠 Found local network IP: ${addr.address}');
                return addr.address;
              }
            }
          }
        }
      }

      return 'localhost';
    } catch (e) {
      print('Error getting computer IP: $e');
      return 'localhost';
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';

void main() {
  runApp(const YemenDataApp());
}

class YemenDataApp extends StatelessWidget {
  const YemenDataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق قاعدة البيانات',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'YE'),
      supportedLocales: const [Locale('ar', 'YE')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

// نموذج بيانات الغرفة
class RoomModel {
  final String id;
  final String title;
  final String adminPasscode;
  final String memberPasscode;
  List<String> columns;
  List<Map<String, dynamic>> submissions;
  List<Map<String, String>> chatMessages;

  RoomModel({
    required this.id,
    required this.title,
    required this.adminPasscode,
    required this.memberPasscode,
    required this.columns,
    List<Map<String, dynamic>>? submissions,
    List<Map<String, String>>? chatMessages,
  })  : submissions = submissions ?? [],
        chatMessages = chatMessages ?? [];
}

// قاعدة بيانات محلية مؤقتة للتجربة
List<RoomModel> globalRooms = [
  RoomModel(
    id: '1',
    title: 'مجموعة البيانات الميدانية - صنعاء',
    adminPasscode: 'admin123',
    memberPasscode: 'mem123',
    columns: ['الاسم الرباعي', 'رقم الهاتف', 'المحافظة', 'الكمية المستلمة'],
  )
];

// 1. الشاشة الرئيسية
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCE1126), // أحمر علم اليمن
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('🇾🇪', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 10),
            const Text('تطبيق إدارة البيانات'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('شاشة الضبط العامة')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000000), // أسود علم اليمن
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('دخول مشرف / إنشاء مجموعة جديدة'),
              onPressed: () => _showCreateRoomDialog(context),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'الغرف والمجموعات المتاحة:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: globalRooms.length,
                itemBuilder: (context, index) {
                  final room = globalRooms[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(
                        room.title, // يظهر العنوان فقط للعامة
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.lock_outline, color: Colors.grey),
                      onTap: () => _showLoginDialog(context, room),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final adminPassCtrl = TextEditingController();
    final memberPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إنشاء مجموعة جديدة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'عنوان المجموعة')),
              TextField(controller: adminPassCtrl, decoration: const InputDecoration(labelText: 'كلمة سر المشرف')),
              TextField(controller: memberPassCtrl, decoration: const InputDecoration(labelText: 'كلمة سر الأعضاء')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                setState(() {
                  globalRooms.add(RoomModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleCtrl.text,
                    adminPasscode: adminPassCtrl.text,
                    memberPasscode: memberPassCtrl.text,
                    columns: ['الاسم', 'الهاتف'],
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('إنشاء'),
          )
        ],
      ),
    );
  }

  void _showLoginDialog(BuildContext context, RoomModel room) {
    final passCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('الدخول إلى: ${room.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسمك / معرف المشارك')),
            TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة السر')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (passCtrl.text == room.adminPasscode) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AdminRoomScreen(room: room)));
              } else if (passCtrl.text == room.memberPasscode) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MemberRoomScreen(room: room, memberName: nameCtrl.text.isEmpty ? 'عضو' : nameCtrl.text)));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمة السر غير صحيحة')));
              }
            },
            child: const Text('دخول'),
          )
        ],
      ),
    );
  }
}

// 2. واجهة العضو
class MemberRoomScreen extends StatefulWidget {
  final RoomModel room;
  final String memberName;

  const MemberRoomScreen({super.key, required this.room, required this.memberName});

  @override
  State<MemberRoomScreen> createState() => _MemberRoomScreenState();
}

class _MemberRoomScreenState extends State<MemberRoomScreen> {
  final Map<String, TextEditingController> _controllers = {};
  Map<String, dynamic>? _lastSubmission;

  @override
  void initState() {
    super.initState();
    for (var col in widget.room.columns) {
      _controllers[col] = TextEditingController();
    }
  }

  void _submitData() {
    final now = DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now());
    Map<String, dynamic> entry = {
      '_memberName': widget.memberName,
      '_submittedAt': now,
    };

    _controllers.forEach((key, ctrl) {
      entry[key] = ctrl.text;
    });

    setState(() {
      _lastSubmission = entry;
      widget.room.submissions.add(entry);
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال البيانات بنجاح')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تعبئة: ${widget.room.title}'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => _openChat(context),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('أهلاً بك: ${widget.memberName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              ...widget.room.columns.map((col) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _controllers[col],
                    decoration: InputDecoration(
                      labelText: col,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      icon: const Icon(Icons.send),
                      label: const Text('إرسال البيانات'),
                      onPressed: _submitData,
                    ),
                  ),
                ],
              ),
              if (_lastSubmission != null) ...[
                const SizedBox(height: 20),
                const Text('آخر ما تم إرساله بواسطة التطبيق:', style: TextStyle(fontWeight: FontWeight.bold)),
                Card(
                  color: Colors.blueGrey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._lastSubmission!.entries.map((e) => Text('${e.key}: ${e.value}')),
                      ],
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _openChat(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(room: widget.room, senderName: widget.memberName)));
  }
}

// 3. واجهة المشرف
class AdminRoomScreen extends StatefulWidget {
  final RoomModel room;
  const AdminRoomScreen({super.key, required this.room});

  @override
  State<AdminRoomScreen> createState() => _AdminRoomScreenState();
}

class _AdminRoomScreenState extends State<AdminRoomScreen> {
  void _addColumn() {
    final colCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة عمود جديد للكشف'),
        content: TextField(controller: colCtrl, decoration: const InputDecoration(labelText: 'اسم العمود')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (colCtrl.text.isNotEmpty) {
                setState(() {
                  widget.room.columns.add(colCtrl.text);
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('إضافة'),
          )
        ],
      ),
    );
  }

  void _exportToExcel() {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['الكشف الشامل'];
    excel.setDefaultSheet('الكشف الشامل');

    List<CellValue> headers = [
      TextCellValue('المشارك'),
      TextCellValue('تاريخ ووقت الإدخال'),
      ...widget.room.columns.map((c) => TextCellValue(c))
    ];
    sheetObject.appendRow(headers);

    for (var sub in widget.room.submissions) {
      List<CellValue> row = [
        TextCellValue(sub['_memberName'] ?? ''),
        TextCellValue(sub['_submittedAt'] ?? ''),
        ...widget.room.columns.map((c) => TextCellValue(sub[c]?.toString() ?? ''))
      ];
      sheetObject.appendRow(row);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تجهيز ملف Excel الحديث بنجاح!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة: ${widget.room.title}'),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(icon: const Icon(Icons.file_download), onPressed: _exportToExcel, tooltip: 'تصدير إلى Excel'),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(room: widget.room, senderName: 'المشرف')));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة عمود حر'),
                  onPressed: _addColumn,
                ),
                Text('إجمالي السجلات: ${widget.room.submissions.length}'),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: [
                      const DataColumn(label: Text('المشارك')),
                      const DataColumn(label: Text('وقت الإدخال')),
                      ...widget.room.columns.map((c) => DataColumn(label: Text(c))),
                    ],
                    rows: widget.room.submissions.map((sub) {
                      return DataRow(
                        cells: [
                          DataCell(Text(sub['_memberName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(sub['_submittedAt'] ?? '', style: const TextStyle(fontSize: 12))),
                          ...widget.room.columns.map((c) => DataCell(Text(sub[c]?.toString() ?? '-'))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. نافذة المحادثة
class ChatScreen extends StatefulWidget {
  final RoomModel room;
  final String senderName;

  const ChatScreen({super.key, required this.room, required this.senderName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المحادثة والملاحظات')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: widget.room.chatMessages.length,
              itemBuilder: (ctx, i) {
                final msg = widget.room.chatMessages[i];
                return ListTile(
                  title: Text(msg['sender']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(msg['text']!),
                  trailing: Text(msg['time']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: const InputDecoration(hintText: 'اكتب ملاحظتك هنا...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: () {
                    if (_msgCtrl.text.isNotEmpty) {
                      setState(() {
                        widget.room.chatMessages.add({
                          'sender': widget.senderName,
                          'text': _msgCtrl.text,
                          'time': DateFormat('hh:mm a').format(DateTime.now()),
                        });
                        _msgCtrl.clear();
                      });
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

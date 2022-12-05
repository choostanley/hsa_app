import 'package:flutter/material.dart';
import 'package:hsa_app/appt/models/pt_noti.dart';
import 'package:hsa_app/common/firebase/firebase_const.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:intl/intl.dart';

import '../../common/functions.dart';

class NotiListTile extends StatefulWidget {
  final PtNoti ptNoti;
  final bool setColor;
  const NotiListTile({super.key, required this.ptNoti, required this.setColor});

  @override
  // ignore: library_private_types_in_public_api
  _NotiListTileState createState() => _NotiListTileState();
}

class _NotiListTileState extends State<NotiListTile> {
  // int title = 0;
  // int subtitle = 0;
  bool changed = false;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            border: Border.all(), borderRadius: BorderRadius.circular(5)),
        child: VisibilityDetector(
          key: Key(
              getRandomString(5)), // need random if not only last item updated
          onVisibilityChanged: (VisibilityInfo info) {
            if (info.visibleFraction == 1 && !changed && !widget.ptNoti.seen) {
              ptNotiRef.doc(widget.ptNoti.id).update({
                'seen': true,
                'updatedAt': DateTime.now().millisecondsSinceEpoch
              });
              changed = true;
            }
          },
          child: ListTile(
              tileColor: widget.setColor ? Colors.white : null,
              isThreeLine: true,
              dense: true,
              title: Text(widget.ptNoti.title),
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.ptNoti.body, overflow: TextOverflow.ellipsis),
                  Text(DateFormat('dd-MM-yyyy kk:mm')
                      .format(widget.ptNoti.createdAt)),
                ],
              ),
              trailing: widget.ptNoti.seen
                  ? const Icon(
                      Icons.mark_email_read,
                      size: 30,
                      color: Colors.blueAccent,
                    )
                  : const Icon(Icons.email, size: 30)),
        ));
  }
}

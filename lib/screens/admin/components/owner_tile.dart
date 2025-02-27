import 'package:bookmywod_admin/screens/admin/add_admin_view.dart';
import 'package:bookmywod_admin/shared/constants/colors.dart';
import 'package:flutter/material.dart';

class OwnerTile extends StatelessWidget {
  final AddAdminView widget;

  const OwnerTile({
    super.key,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundImage: widget.userModel.avatarUrl != null
            ? NetworkImage(widget.userModel.avatarUrl!)
            : const AssetImage('assets/home/default_profile.png')
                as ImageProvider,
      ),
      title: Text(widget.userModel.fullName),
      subtitle: Text(widget.authUser.email),
      trailing: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: customGrey, width: 1),
        ),
        child: const Text(
          'Owner',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

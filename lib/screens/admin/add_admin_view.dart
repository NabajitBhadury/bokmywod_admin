// ignore_for_file: use_build_context_synchronously

import 'package:bookmywod_admin/screens/admin/components/owner_tile.dart';
import 'package:bookmywod_admin/shared/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:bookmywod_admin/services/auth/auth_user.dart';
import 'package:bookmywod_admin/services/database/models/trainer_model.dart';
import 'package:bookmywod_admin/services/database/supabase_storage/supabase_db.dart';
import 'package:bookmywod_admin/shared/constants/colors.dart';

class AddAdminView extends StatefulWidget {
  final AuthUser authUser;
  final SupabaseDb supabaseDb;
  final TrainerModel userModel;

  const AddAdminView({
    super.key,
    required this.authUser,
    required this.supabaseDb,
    required this.userModel,
  });

  @override
  State<AddAdminView> createState() => _AddAdminViewState();
}

class _AddAdminViewState extends State<AddAdminView> {
  late final TextEditingController _searchController;
  List<TrainerModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (!mounted) return;

    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSearching = true;
      });
    }

    try {
      final results = await widget.supabaseDb.searchTrainersByName(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = widget.userModel.authId;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Add Admin',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Member',
                style: TextStyle(fontSize: 20),
              ),
              OwnerTile(widget: widget),
              const Divider(color: Colors.white10, thickness: 2),
              const Text(
                'Admins',
                style: TextStyle(fontSize: 16),
              ),
              const Divider(color: Colors.white10, thickness: 2),
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                ),
                child: TextField(
                  controller: _searchController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: _searchUsers,
                  decoration: InputDecoration(
                    hintText: 'Enter admin name',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => _searchUsers(_searchController.text),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: customBlue,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'Add Now',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: customDarkBlue,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user.avatarUrl != null
                                ? NetworkImage(user.avatarUrl!)
                                : const AssetImage(
                                        'assets/home/default_profile.png')
                                    as ImageProvider,
                          ),
                          title: Text(user.fullName),
                          subtitle: Text(user.username ?? ''),
                          onTap: () async {
                            try {
                              String uid = widget.userModel.authId;

                              // AdminModel? admin =
                              //     await widget.supabaseDb.getAdminbyUid(uid);
                              // var uuid = Uuid().v4();
                              // if (admin == null) {
                              //   admin = await widget.supabaseDb.createAdmin(
                              //     AdminModel(
                              //         adminId: uuid,
                              //         uidList: [
                              //           {'uid': user.authId, 'isEnabled': true}
                              //         ],
                              //         uid: uid),
                              //   );
                              // } else {
                              //   if (!admin.uidList
                              //       .any((e) => e['uid'] == user.authId)) {
                              //     List<Map<String, dynamic>> updatedUidList = [
                              //       ...admin.uidList,
                              //       {'uid': user.authId, 'isEnabled': true}
                              //     ];
                              //     await widget.supabaseDb.updateAdmin(
                              //         admin.copyWith(uidList: updatedUidList));
                              //   }
                              // }

                              showSnackbar(
                                context,
                                '${user.fullName} added as admin',
                                type: SnackbarType.success,
                              );
                            } catch (e) {
                              showSnackbar(
                                context,
                                e.toString(),
                                type: SnackbarType.success,
                              );
                            }
                          },
                        );
                      },
                    ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

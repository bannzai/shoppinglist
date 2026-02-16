import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/group_create.dart';

class GroupCreatePage extends HookConsumerWidget {
  const GroupCreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final isCreating = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('グループ作成'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'グループ名',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'グループ名を入力',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isCreating.value
                      ? null
                      : () async {
                          isCreating.value = true;
                          try {
                            final appUser =
                                ref.read(appUserProvider).asData?.value;
                            if (appUser == null) {
                              throw StateError('AppUser is not available');
                            }
                            await ref.read(createGroupProvider).call(
                                  appUser: appUser,
                                  name: nameController.text.isNotEmpty
                                      ? nameController.text
                                      : null,
                                  setAsDefault: false,
                                );
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          } finally {
                            isCreating.value = false;
                          }
                        },
                  child: isCreating.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('作成する'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:healthy_cook/components/feedback.dart';
import 'package:healthy_cook/components/image_picking.dart';
import 'package:healthy_cook/components/user_avatar.dart';
import 'package:healthy_cook/data/api_client.dart';
import 'package:healthy_cook/data/api_exception.dart';
import 'package:healthy_cook/data/auth_controller.dart';
import 'package:healthy_cook/data/recipe_repository.dart';
import 'package:provider/provider.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  ImageUpload? image;
  String newUsername = '';
  bool _saving = false;

  /// Envia só o que mudou. O nome e a foto aparecem nas receitas por JOIN na
  /// API, então não é mais preciso atualizar cada receita.
  Future<void> changeUserData(BuildContext dialogContext) async {
    final auth = context.read<AuthController>();
    final recipes = context.read<RecipeRepository>();
    final name = newUsername.trim();
    if (image == null && name.isEmpty) {
      showErrorSnackBar(context, 'Nenhuma alteração realizada');
      Navigator.of(dialogContext).pop();
      return;
    }
    if (name.isNotEmpty && name.length < 2) {
      showErrorSnackBar(context, 'O nome deve ter pelo menos 2 caracteres');
      return;
    }

    setState(() => _saving = true);
    try {
      if (image != null) await auth.updatePhoto(image!);
      if (name.isNotEmpty) await auth.updateName(name);
      recipes.refreshLists();
      if (!mounted) return;
      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
      showSuccessSnackBar(context, 'Dados alterados com sucesso');
    } on ApiException catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.userMessage);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> resendVerification() async {
    try {
      await context.read<AuthController>().resendEmailVerification();
      if (!mounted) return;
      showSuccessSnackBar(context, 'Enviamos um novo link de confirmação');
    } on ApiException catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.userMessage);
    }
  }

  void changaDataProfile(BuildContext context) {
    image = null;
    newUsername = '';
    showDialog(
      context: context,
      builder: (dialogContext) =>
          StatefulBuilder(builder: (dialogContext, setDialogState) {
        return AlertDialog(
          title: const Text(
            "Editar Perfil",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF1C4036)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () async {
                    final picked = await pickImageFromGallery();
                    if (picked != null) setDialogState(() => image = picked);
                  },
                  child: Container(
                    width: double.maxFinite,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: image != null
                        ? Image.memory(image!.bytes)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.insert_photo_outlined,
                                color: Color(0xFF1C4036),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                'Inserir Imagem',
                                style: TextStyle(
                                    fontSize: 16.0, color: Color(0xFF1C4036)),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  maxLength: 100,
                  onChanged: (value) => newUsername = value,
                  decoration: InputDecoration(
                    labelText: "Novo nome de perfil",
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF1C4036)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1C4036))),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(color: Color(0xFF1C4036)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C4036)),
                      onPressed: _saving
                          ? null
                          : () async {
                              setDialogState(() {});
                              await changeUserData(dialogContext);
                            },
                      child: const Text(
                        "Enviar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    if (user == null) return const SizedBox.shrink();

    return Column(
      children: [
        UserAvatar(photoUrl: user.photoUrl, radius: 50),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    user.name,
                    style: const TextStyle(
                        fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            if (user.emailVerified)
              const Icon(
                Icons.verified_outlined,
              ),
          ],
        ),
        if (!user.emailVerified)
          TextButton(
            onPressed: resendVerification,
            child: const Text(
              'E-mail não confirmado. Reenviar link',
              style: TextStyle(color: Color(0xFF18592F)),
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C4036)),
          onPressed: () => changaDataProfile(context),
          child: const Text(
            'Editar perfil',
            style: TextStyle(color: Color(0xFFF2F2F2)),
          ),
        ),
      ],
    );
  }
}

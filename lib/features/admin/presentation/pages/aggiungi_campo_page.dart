import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_campi/core/services/campi_service.dart';
import 'package:app_campi/core/theme/app_theme.dart';

class AggiungiCampo extends StatefulWidget {
  final String idSocieta;
  final Map<String, dynamic>? campoEsistente;

  const AggiungiCampo({
    super.key,
    required this.idSocieta,
    this.campoEsistente,
  });

  @override
  State<AggiungiCampo> createState() => _AggiungiCampoState();
}

class _AggiungiCampoState extends State<AggiungiCampo> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  late final CampiService _campiService;

  final _nomeController = TextEditingController();
  final _prezzoController = TextEditingController();

  int _numeroGiocatori = 5;
  final List<int> _opzioniGiocatori = [5, 7, 8, 11];

  bool _isCoperto = false;
  bool _isCaricamento = false;

  String? _fotoUrl;
  Uint8List? _fotoBytesLocali;
  String? _estensioneFotoLocale;

  @override
  void initState() {
    super.initState();
    _campiService = CampiService();

    if (widget.campoEsistente != null) {
      final c = widget.campoEsistente!;
      _nomeController.text = c['nome_campo'] ?? '';
      _prezzoController.text = (c['prezzo'] ?? 0).toString();
      _isCoperto = c['coperto'] ?? false;
      _fotoUrl = c['foto_url'];

      final int valoreDb = c['numero_di_giocatori'] ?? 10;
      final int valoreMostrato = valoreDb ~/ 2;
      _numeroGiocatori = _opzioniGiocatori.contains(valoreMostrato)
          ? valoreMostrato
          : 5;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _prezzoController.dispose();
    super.dispose();
  }

  Future<void> _selezionaFotoCampo() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      String estensione = 'jpg';
      if (image.name.contains('.')) {
        estensione = image.name.split('.').last;
      }
      setState(() {
        _fotoBytesLocali = bytes;
        _estensioneFotoLocale = estensione;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore selezione foto: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _rimuoviFotoCampo() {
    setState(() {
      _fotoBytesLocali = null;
      _estensioneFotoLocale = null;
      _fotoUrl = null;
    });
  }

  void _salvaCampo() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isCaricamento = true);

      try {
        final double prezzoConvertito = double.parse(
          _prezzoController.text.trim().replaceAll(',', '.'),
        );

        String? idCampoAttuale;

        if (widget.campoEsistente == null) {
          await _campiService.salvaCampo(
            idSocieta: widget.idSocieta,
            nomeCampo: _nomeController.text.trim(),
            numeroGiocatori: _numeroGiocatori,
            prezzo: prezzoConvertito,
            isCoperto: _isCoperto,
          );

          final ultimoCampo = await Supabase.instance.client
              .from('campi')
              .select('id')
              .eq('id_societa', widget.idSocieta)
              .eq('nome_campo', _nomeController.text.trim())
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

          idCampoAttuale = ultimoCampo?['id']?.toString();
        } else {
          idCampoAttuale = widget.campoEsistente!['id'].toString();
          await _campiService.aggiornaCampo(
            idCampo: widget.campoEsistente!['id'],
            nomeCampo: _nomeController.text.trim(),
            numeroGiocatori: _numeroGiocatori,
            prezzo: prezzoConvertito,
            isCoperto: _isCoperto,
          );
        }

        // GESTIONE FOTO
        if (idCampoAttuale != null) {
          if (_fotoBytesLocali != null && _estensioneFotoLocale != null) {
            final fileName =
                'campo_${idCampoAttuale}_${DateTime.now().millisecondsSinceEpoch}.$_estensioneFotoLocale';
            await Supabase.instance.client.storage
                .from('avatar_societa')
                .uploadBinary(
                  fileName,
                  _fotoBytesLocali!,
                  fileOptions: const FileOptions(upsert: true),
                );
            final String publicUrl = Supabase.instance.client.storage
                .from('avatar_societa')
                .getPublicUrl(fileName);
            await Supabase.instance.client
                .from('campi')
                .update({'foto_url': publicUrl})
                .eq('id', idCampoAttuale);
          } else if (_fotoUrl == null &&
              widget.campoEsistente != null &&
              widget.campoEsistente!['foto_url'] != null) {
            await Supabase.instance.client
                .from('campi')
                .update({'foto_url': null})
                .eq('id', idCampoAttuale);
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.campoEsistente == null
                    ? 'Campo aggiunto! 🎉'
                    : 'Campo modificato! ✏️',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isCaricamento = false);
      }
    }
  }

  InputDecoration _stileInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade400),
      prefixIcon: Icon(icon, color: AppTheme.neonOrange),
      filled: true,
      fillColor: AppTheme.cardBg,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppTheme.neonOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isModifica = widget.campoEsistente != null;
    final bool urlValido =
        _fotoUrl != null && _fotoUrl!.trim().isNotEmpty && _fotoUrl != 'null';
    final bool haImmagine = _fotoBytesLocali != null || urlValido;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: Text(isModifica ? 'Modifica Campo' : 'Inserisci Campo'),
        iconTheme: const IconThemeData(color: AppTheme.neonOrange),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NOME CAMPO
                  TextFormField(
                    controller: _nomeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _stileInput(
                      'Nome Campo *',
                      Icons.sports_soccer,
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Inserisci un nome'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // NUMERO GIOCATORI
                  DropdownButtonFormField<int>(
                    value: _numeroGiocatori,
                    dropdownColor: AppTheme.cardBg,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: _stileInput('Tipo di Campo *', Icons.people),
                    items: _opzioniGiocatori
                        .map(
                          (val) => DropdownMenuItem(
                            value: val,
                            child: Text('Calcio a $val'),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _numeroGiocatori = val!),
                  ),
                  const SizedBox(height: 20),

                  // PREZZO
                  TextFormField(
                    controller: _prezzoController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: _stileInput('Prezzo orario (€) *', Icons.euro),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty)
                        return 'Inserisci il prezzo';
                      final parsed = double.tryParse(
                        val.trim().replaceAll(',', '.'),
                      );
                      if (parsed == null || parsed < 0)
                        return 'Inserisci un prezzo valido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // COPERTO
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade700),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Campo Coperto',
                        style: TextStyle(color: Colors.white),
                      ),
                      activeThumbColor: AppTheme.neonOrange,
                      value: _isCoperto,
                      onChanged: (val) => setState(() => _isCoperto = val),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // FOTO CAMPO
                  const Text(
                    'Foto Campo (Facoltativa)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: haImmagine
                            ? AppTheme.neonOrange
                            : Colors.grey.shade700,
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_fotoBytesLocali != null)
                            Image.memory(_fotoBytesLocali!, fit: BoxFit.cover)
                          else if (urlValido)
                            Image.network(
                              _fotoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                        size: 36,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Immagine non disponibile',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                            )
                          else
                            GestureDetector(
                              onTap: _selezionaFotoCampo,
                              behavior: HitTestBehavior.opaque,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_a_photo,
                                    color: AppTheme.neonOrange,
                                    size: 36,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Clicca per caricare una foto del campo',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (haImmagine)
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: _selezionaFotoCampo,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.neonOrange,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.black,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: _rimuoviFotoCampo,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // BOTTONE SALVA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isCaricamento ? null : _salvaCampo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonOrange,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isCaricamento
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isModifica ? 'Salva Modifiche' : 'Salva Campo',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

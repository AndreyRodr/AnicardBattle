import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/quest_service.dart';

class QuestsDialog extends StatefulWidget {
  const QuestsDialog({super.key});

  @override
  State<QuestsDialog> createState() => _QuestsDialogState();
}

class _QuestsDialogState extends State<QuestsDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  final QuestService _questService = QuestService();

  final List<Map<String, dynamic>> _recompensasDiariasConfig = [
    {'dia': 1, 'tipo': 'moeda', 'qtd': 50},
    {'dia': 2, 'tipo': 'moeda', 'qtd': 100},
    {'dia': 3, 'tipo': 'moeda', 'qtd': 150},
    {'dia': 4, 'tipo': 'moeda', 'qtd': 200},
    {'dia': 5, 'tipo': 'moeda', 'qtd': 250},
    {'dia': 6, 'tipo': 'moeda', 'qtd': 300},
    {'dia': 7, 'tipo': 'pacote', 'qtd': 1, 'nome': 'Pacote Épico'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (_uid != null) {
      _questService.verificarEGerarMissoes(_uid!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _obterDataHojeFormatada() {
    final hoje = DateTime.now();
    return "${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}";
  }

  Future<void> _coletarRecompensaDiaria(int diaAlvo, int qtdMoedas, String tipo) async {
    if (_uid == null) return;
    final docRef = FirebaseFirestore.instance.collection('users').doc(_uid);
    final hojeStr = _obterDataHojeFormatada();

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final dados = snapshot.data() as Map<String, dynamic>;
        int moedasAtuais = dados['moedas'] ?? 0;

        if (tipo == 'moeda') moedasAtuais += qtdMoedas;

        transaction.update(docRef, {
          'moedas': moedasAtuais,
          'recompensaDiaria.ultimoLoginColetado': hojeStr,
          'recompensaDiaria.sequenciaAtual': diaAlvo,
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dia $diaAlvo coletado com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Erro prêmio diário: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) return const SizedBox.shrink();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350,
        height: 480,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF351F14), 
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.6), offset: const Offset(0, 4), blurRadius: 12),
          ],
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(_uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.amber));
            }

            Map<String, dynamic> dadosDiarios = {};
            List<dynamic> diarias = [];
            List<dynamic> semanais = [];
            int ultimaGeracaoDiariaMs = 0;
            int ultimaGeracaoSemanalMs = 0;

            if (snapshot.hasData && snapshot.data!.exists) {
              final dadosGerais = snapshot.data!.data() as Map<String, dynamic>;
              dadosDiarios = dadosGerais['recompensaDiaria'] as Map<String, dynamic>? ?? {};
              diarias = dadosGerais['missoesDiarias'] as List<dynamic>? ?? [];
              semanais = dadosGerais['missoesSemanais'] as List<dynamic>? ?? [];
              
              ultimaGeracaoDiariaMs = dadosGerais['ultimaGeracaoDiariaMs'] ?? 0;
              ultimaGeracaoSemanalMs = dadosGerais['ultimaGeracaoSemanalMs'] ?? 0;
            }

            final String ultimoColetado = dadosDiarios['ultimoLoginColetado'] ?? "";
            final int sequenciaAtual = dadosDiarios['sequenciaAtual'] ?? 0;
            final String hojeStr = _obterDataHojeFormatada();
            final bool jaColetouHoje = ultimoColetado == hojeStr;

            int proximoDiaElegivel = sequenciaAtual + 1;
            if (jaColetouHoje) proximoDiaElegivel = -1;
            if (sequenciaAtual >= 7 && !jaColetouHoje) proximoDiaElegivel = 1;

            return Column(
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.amber,
                  labelColor: Colors.amber,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: const [
                    Tab(text: 'DIÁRIO', icon: Icon(Icons.calendar_month)),
                    Tab(text: 'MISSÕES', icon: Icon(Icons.emoji_events)),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCalendarioTab(sequenciaAtual, proximoDiaElegivel),
                      _buildMissoesTab(diarias, semanais, ultimaGeracaoDiariaMs, ultimaGeracaoSemanalMs),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5E35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('FECHAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarioTab(int sequencia, int proximoDia) {
    final configDia7 = _recompensasDiariasConfig.last;
    final List<Map<String, dynamic>> primeirosDiasConfig = _recompensasDiariasConfig.sublist(0, 6);

    final bool concluidoDia7 = 7 <= sequencia && proximoDia != 1;
    final bool disponivelHojeDia7 = 7 == proximoDia;

    Color fundoDia7 = Colors.black.withOpacity(0.25);
    Color bordaDia7 = Colors.white10;
    if (concluidoDia7) {
      fundoDia7 = Colors.green.withOpacity(0.15);
      bordaDia7 = Colors.green.withOpacity(0.5);
    } else if (disponivelHojeDia7) {
      fundoDia7 = Colors.amber.withOpacity(0.12);
      bordaDia7 = Colors.amber;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
            child: Text(
              "Faça login todos os dias para adquirir recompensas!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.amber.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.15, 
            ),
            itemCount: primeirosDiasConfig.length,
            itemBuilder: (context, index) {
              final config = primeirosDiasConfig[index];
              final int dia = config['dia'];
              final int qtd = config['qtd'];

              final bool concluido = dia <= sequencia && proximoDia != 1;
              final bool disponivelHoje = dia == proximoDia;

              Color corFundo = Colors.black.withOpacity(0.25);
              Color corBorda = Colors.white10;

              if (concluido) {
                corFundo = Colors.green.withOpacity(0.15);
                corBorda = Colors.green.withOpacity(0.5);
              } else if (disponivelHoje) {
                corFundo = Colors.amber.withOpacity(0.12);
                corBorda = Colors.amber;
              }

              return GestureDetector(
                onTap: disponivelHoje ? () => _coletarRecompensaDiaria(dia, qtd, config['tipo']) : null,
                child: Container(
                  decoration: BoxDecoration(color: corFundo, borderRadius: BorderRadius.circular(12), border: Border.all(color: corBorda, width: 1.5)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Dia $dia', style: TextStyle(color: disponivelHoje ? Colors.amber : Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Icon(Icons.monetization_on, color: concluido ? Colors.greenAccent : Colors.amber, size: 24),
                      const SizedBox(height: 4),
                      Text('$qtd', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: disponivelHojeDia7 ? () => _coletarRecompensaDiaria(7, configDia7['qtd'], configDia7['tipo']) : null,
            child: Container(
              height: 80, 
              decoration: BoxDecoration(color: fundoDia7, borderRadius: BorderRadius.circular(12), border: Border.all(color: bordaDia7, width: 2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 20),
                  Icon(Icons.card_giftcard, color: concluidoDia7 ? Colors.greenAccent : Colors.amber, size: 38),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RECOMPENSA MÁXIMA - DIA 7', style: TextStyle(color: disponivelHojeDia7 ? Colors.amber : Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        Text('${configDia7['nome']}', style: const TextStyle(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  if (disponivelHojeDia7) const Padding(padding: EdgeInsets.only(right: 16.0), child: Icon(Icons.touch_app, color: Colors.amber, size: 22)),
                  if (concluidoDia7) const Padding(padding: EdgeInsets.only(right: 16.0), child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 24)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 MODIFICADO: Agora recebe os timestamps brutos do banco e delega o relógio para os Headers isolados
  Widget _buildMissoesTab(List<dynamic> diarias, List<dynamic> semanais, int diariaMs, int semanalMs) {
    if (diarias.isEmpty && semanais.isEmpty) {
      return const Center(
        child: Text('Carregando missões...', style: TextStyle(color: Colors.white60, fontSize: 14)),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        if (diarias.isNotEmpty) ...[
          // 🌟 HEADER ISOLADO COM TIMEOUT PRÓPRIO
          CountdownHeader(
            titulo: 'MISSÕES DIÁRIAS',
            corTexto: Colors.amber,
            timestampBaseMs: diariaMs,
            ehSemanal: false,
          ),
          ...diarias.map((m) => _buildCardMissao(m, false)),
        ],
        
        const SizedBox(height: 16),
        
        if (semanais.isNotEmpty) ...[
          // 🌟 HEADER ISOLADO COM TIMEOUT PRÓPRIO
          CountdownHeader(
            titulo: 'MISSÕES SEMANAIS',
            corTexto: Colors.cyanAccent,
            timestampBaseMs: semanalMs,
            ehSemanal: true,
          ),
          ...semanais.map((m) => _buildCardMissao(m, true)),
        ],
      ],
    );
  }

  Widget _buildCardMissao(Map<String, dynamic> m, bool ehSemanal) {
    final String id = m['id'] ?? '';
    final String titulo = m['titulo'] ?? 'Missão';
    final int progresso = m['progresso'] ?? 0;
    final int meta = m['meta'] ?? 1;
    final bool coletado = m['coletado'] ?? false;
    final int premioMoedas = m['premioMoedas'] ?? 0;
    
    final bool completo = progresso >= meta;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('+$premioMoedas ', style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 12),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (progresso / meta).clamp(0.0, 1.0),
                    backgroundColor: Colors.white10,
                    color: completo ? Colors.greenAccent : (ehSemanal ? Colors.cyanAccent : Colors.amber),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 32,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: coletado ? Colors.black26 : (completo ? Colors.green : Colors.grey.withOpacity(0.15)),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: completo && !coletado ? () {
                _questService.coletarPremioMissao(
                  uid: _uid!,
                  idMissao: id,
                  ehSemanal: ehSemanal,
                  moedasPremio: premioMoedas,
                );
              } : null,
              child: Text(
                coletado ? 'OK' : (completo ? 'PEGAR' : '$progresso/$meta'),
                style: TextStyle(color: completo && !coletado ? Colors.white : Colors.white60, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🌟 NOVO COMPONENTE: GERENCIA O PRÓPRIO CRONÔMETRO INDEPENDENTE SEM PISCAR A TELA GERAL
class CountdownHeader extends StatefulWidget {
  final String titulo;
  final Color corTexto;
  final int timestampBaseMs;
  final bool ehSemanal;

  const CountdownHeader({
    super.key,
    required this.titulo,
    required this.corTexto,
    required this.timestampBaseMs,
    required this.ehSemanal,
  });

  @override
  State<CountdownHeader> createState() => _CountdownHeaderState();
}

class _CountdownHeaderState extends State<CountdownHeader> {
  Timer? _timer;
  String _relogioStr = "00:00:00";

  @override
  void initState() {
    super.initState();
    _atualizarRelogio();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _atualizarRelogio());
  }

  @override
  void didUpdateWidget(covariant CountdownHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timestampBaseMs != widget.timestampBaseMs) {
      _atualizarRelogio();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _atualizarRelogio() {
    if (widget.timestampBaseMs == 0) return;

    final int agoraMs = DateTime.now().millisecondsSinceEpoch;
    final int limiteMs = widget.ehSemanal ? (168 * 60 * 60 * 1000) : (24 * 60 * 60 * 1000);
    final int restanteMs = (widget.timestampBaseMs + limiteMs) - agoraMs;

    if (restanteMs <= 0) {
      if (mounted) setState(() => _relogioStr = "00:00:00");
      return;
    }

    int segundosTotais = restanteMs ~/ 1000;
    int horas = segundosTotais ~/ 3600;
    int minutos = (segundosTotais % 3600) ~/ 60;
    int segundos = segundosTotais % 60;

    if (mounted) {
      setState(() {
        _relogioStr = "${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.titulo, 
            style: TextStyle(color: widget.corTexto, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          Text(
            '(Redefinirá em $_relogioStr)', 
            style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
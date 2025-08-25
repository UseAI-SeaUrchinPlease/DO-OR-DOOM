import 'package:flutter/material.dart';

class TaskEdit extends StatelessWidget {
  const TaskEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('タスクの編集'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.65, // 画面の60%の高さに制限
        child: SingleChildScrollView(
          // スクロール可能にする
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タスク名セクション
              _buildTaskNameSection(),
              const SizedBox(height: 16),

              // 期日セクション
              _buildDueDateSection(),
              const SizedBox(height: 16),

              // 詳細セクション
              _buildDetailsSection(),
              const SizedBox(height: 28),

              // AIボタンセクション
              _buildAIButton(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    );
  }

  Widget _buildTaskNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'タスク名',
          style: TextStyle(
            color: Color(0xFF1D1B20),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: const Color(0xFFE6E0E9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.5),
            ),
          ),
          child: const Text(
            'プロダクト完成',
            style: TextStyle(
              color: Color(0xFF1D1B20),
              fontSize: 18,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              height: 1.50,
              letterSpacing: 0.56,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDueDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '期日',
          style: TextStyle(
            color: Color(0xFF1D1B20),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: const Color(0xFFE6E0E9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.5),
            ),
          ),
          child: const Text(
            '2025/08/26',
            style: TextStyle(
              color: Color(0xFF1D1B20),
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              height: 1.69,
              letterSpacing: 0.56,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '詳細',
          style: TextStyle(
            color: Color(0xFF1D1B20),
            fontSize: 18,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 100,
            maxHeight: 200, // 最大高さを制限
          ),
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: const Color(0xFFE6E0E9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.5),
            ),
          ),
          child: const SingleChildScrollView(
            child: Text(
              'くぅ～疲れましたw これにて完結です！\n実は、ネタレスしたら代行の話を持ちかけられたのが始まりでした\n本当は話のネタなかったのですが←\nご厚意を無駄にするわけには行かないので流行りのネタで挑んでみた所存ですw\n以下、まどか達のみんなへのメッセジをどぞ\nまどか「みんな、見てくれてありがとう\nちょっと腹黒なところも見えちゃったけど・・・気にしないでね！」\nさやか「いやーありがと！\n私のかわいさは二十分に伝わったかな？」\nマミ「見てくれたのは嬉しいけどちょっと恥ずかしいわね・・・」\n京子「見てくれありがとな！\n正直、作中で言った私の気持ちは本当だよ！」\nほむら「・・・ありがと」ﾌｧｻ\nでは、\nまどか、さやか、マミ、京子、ほむら、俺「皆さんありがとうございました！」\n終\nまどか、さやか、マミ、京子、ほむら「って、なんで俺くんが！？\n改めまして、ありがとうございました！」\n本当の本当に終わり',
              style: TextStyle(
                color: Color(0xFF1D1B20),
                fontSize: 14,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                height: 1.57,
                letterSpacing: 0.56,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAIButton() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFEADDFF) /* Schemes-Primary-Container */,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadows: [
          BoxShadow(
            color: Color(0x4C000000),
            blurRadius: 3,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, 4),
            spreadRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: Image.asset('assets/icons/calendar-ai.png'),
                ),
                Text(
                  'AI絵日記を見てみる',
                  style: TextStyle(
                    color: const Color(
                      0xFF4F378A,
                    ) /* Schemes-On-Primary-Container */,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                    letterSpacing: 0.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

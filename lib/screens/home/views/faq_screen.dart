import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:waste_management_app/constants/fonts.dart';
import 'package:waste_management_app/constants/styles.dart';
import 'package:waste_management_app/screens/profile/data/faqs.dart';
import 'package:waste_management_app/sharedWidgets/top_header_with_back.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopHeaderWithBackButton(
                title: 'FAQs',
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: faqList.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 20.0,
                      ),
                      child: ExpandablePanel(
                        theme: expandableTheme,
                        header: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Q${index + 1}: ${faqList[index].question}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        collapsed: const SizedBox.shrink(),
                        expanded: Padding(
                          padding: const EdgeInsets.only(
                            top: 16,
                          ),
                          child: Text(
                            faqList[index].answer,
                            style: kSubtitleStyle.copyWith(fontSize: 14),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

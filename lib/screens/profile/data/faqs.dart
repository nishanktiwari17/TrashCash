class FAQ {
  final String question;
  final String answer;

  FAQ({required this.question, required this.answer});
}

List<FAQ> faqList = [
  FAQ(
    question: 'How can I schedule a waste pickup through the app?',
    answer:
        'To schedule a waste pickup, simply open the app and navigate to the schedule a waste pickup section (Second Tab). Click on the Add A Trash Pickup Button on the bottom right corner. Choose a convenient date and time, provide your address details, and select the type of waste you want to dispose of. Our team will then confirm the pickup and handle the rest.',
  ),
  FAQ(
    question: 'What types of waste can be picked up through the app?',
    answer:
        'Our waste pickup app accepts various types of waste, including general household waste, recyclable materials, electronic waste (e-waste), and organic waste. We strive to provide comprehensive waste management solutions for our users',
  ),
  FAQ(
    question: 'How do I get rewarded for the waste?',
    answer:
        'Upon successful picking up of trash our team will then proceed to verifying the waste and depeding upon the size of the waste you would be rewarded some points which you can claim.',
  ),
  FAQ(
    question:
        'Is there a minimum order requirement for waste pickup?',
    answer:
        'We have a flexible approach to accommodate our users needs. There is no minimum order requirement for waste pickup, whether you have a small amount or a large quantity to dispose of.',
  ),
];

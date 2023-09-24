import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:flutter/material.dart';

class SearchAlgolia extends StatefulWidget {
  const SearchAlgolia({Key? key}) : super(key: key);

  @override
  State<SearchAlgolia> createState() => _SearchAlgoliaState();
}

class _SearchAlgoliaState extends State<SearchAlgolia> {
  final hitsSearcher = HitsSearcher(
    apiKey: '8edf391b71066e8d6a2db8ee78a91c76',
    applicationID: 'Q5SEP4O5F4',
    indexName: 'healthycook',
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (input) => hitsSearcher.query(input),
            decoration: const InputDecoration(
              hintText: 'Digite sua busca',
            ),
          ),
        ),
        StreamBuilder<SearchResponse>(
          stream: hitsSearcher.responses,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              final response = snapshot.data;
              final hits = response?.hits.toList() ?? [];

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: hits.length,
                itemBuilder: (_, i) => ListTile(
                  leading: Image.network(
                    hits[i]['urlImage'],
                    fit: BoxFit.contain,
                    width: 100,
                    height: 100,
                  ),
                  title: Text(hits[i]['title']),
                  subtitle: Text(
                      '${hits[i]['likes'].length.toString()} ${hits[i]['likes'] == 1 ? "curtida" : "curtidas"}'),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ],
    );
  }
}

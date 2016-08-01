module ApplicationHelper
  def default_meta_tags
    {
        site: 'PokéTalk | ポケトーク',
        reverse: true,
        separator: '-',
        description: 'PokéTalk (ポケトーク) は近くにいるポケモンGoプレイヤー同士でチャットができるサービスです',
        keywords: %w(ポケモン Pokemon ポケモンゴー ポケモンGO PokemonGo PokémonGO ポケモン攻略 ポケモンの巣 ポケモンチャット),
        og: {
          title: :title,
          type: 'website',
          image: '/og.jpg',
          description: :description
        },
        twitter: {
          card: 'summary_large_image',
          site: '@poketalk_jp',
          image: '/og.jpg',
          title: :title,
          description: :description
        }
    }
  end
end

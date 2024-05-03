# create the BIN_DIR global variable if it does not already exist. Use this variable to access the absolute of this scripts location.
export | grep -q 'declare -x BIN_DIR=' || export BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function testing() {
    source "${BIN_DIR}/../lib/configuration-utils.sh";
    libraries;

    declare -A FRUITS=(
        [Apple]='An apple a day keeps the doctor away.'
        [Banana]='Bananas are berries, but strawberries are not.'
        [Cherry]='Cherries are a member of the rose family.'
        [Date]='Dates are one of the world’s oldest cultivated fruits.'
        [Elderberry]='Elderberries are packed with antioxidants and vitamins.'
        [Fig]='Figs are one of the highest plant sources of calcium and fiber.'
        [Grape]='Grapes explode when you put them in the microwave.'
        [Honeydew]='Honeydew melons are part of the cucumber family.'
        [Italian_Plum]='Italian plums are also known as prune plums.'
        [Jackfruit]='Jackfruit is the largest tree-borne fruit in the world.'
        [Kiwi]='Kiwis contain more Vitamin C than oranges.'
        [Lemon]='Lemons are technically berries.'
        [Mango]='Mangoes are related to cashews and pistachios.'
        [Nectarine]='Nectarines are just peaches without the fuzz.'
        [Orange]='Oranges are not even in the top ten list of common foods when it comes to vitamin C levels.'
        [Papaya]='Papayas were once called "fruit of the angels" by Christopher Columbus.'
        [Quince]='Quince is one of the only fruits that can’t be eaten raw.'
        [Raspberry]='Raspberries are a member of the rose family.'
        [Strawberry]='Strawberries are the only fruit with seeds on the outside.'
        [Tomato]='Tomatoes are fruits and part of the nightshade family.'
        [Ugli_Fruit]='Ugli fruit is a hybrid between a grapefruit, an orange, and a tangerine.'
        [Vanilla]='Vanilla comes from an orchid plant and is technically a fruit.'
        [Watermelon]='Watermelons are 92% water.'
        [Xigua]='Xigua is another name for watermelon in Africa.'
        [Yuzu]='Yuzu is a citrus fruit from East Asia that tastes like a cross between a lemon, a mandarin orange, and a grapefruit.'
    );

#optionManager ARGS

#X=$(awkCompletion 'tsh' 'both' 'keys' 'values') || echo 'errors';

#eval "FRUITS$(optionManager -a 'Zucchini=Zucchini is technically a fruit, although it is treated as a vegetable in cooking.' -A FRUITS)"
optionManager -G 'Yuzu,Xigua,Watermelon' -k ' s' -a 'Zucchini=Zucchini is= =technically a fruit, although it is treated as a vegetable in cooking.' -A FRUITS

#echo ${!FRUITS[@]} | grep 'Zu'
#optionManager -a "Yuzu"="Zucchini is technically a fruit, although it is treated as a vegetable in cooking." -A FRUITS
#optionManager -a 'Apple'='An apple a day keeps the doctor away.' -A FRUITS

#initSystem NetworkManager

#echo $?

#isUniqueKey -Q -p 'ijs=g' ARGS
#awkIndexer -g 'key' ARGS
#echo "${ARGS[@]}"
}

testing;

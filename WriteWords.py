import random
import argparse

words = [
    "дом", "кот", "солнце", "человек", "дерево", "машина", "река", "книга", "стол", "окно",
    "цветок", "собака", "лес", "дождь", "город", "птица", "звезда", "день", "ночь", "море",
    "рыба", "гора", "земля", "воздух", "небо", "огонь", "снег", "луна", "вода", "трава",
    "дорога", "сад", "ветер", "песок", "корабль", "камень", "пещера", "метро", "улица", "автобус",
    "поезд", "зима", "лето", "осень", "весна", "картина", "учебник", "школа", "время", "ключ"
]

def append_random_words(file_path, n):
    with open(file_path, 'a', encoding='utf-8') as file:
        for _ in range(n):
            random_word = random.choice(words)
            file.write(random_word + ' ')
    
    print(f"{n} слов добавлено в файл.")

def main():
    parser = argparse.ArgumentParser(description="Записывает случайные слова в файл.")
    
    parser.add_argument('-n', type=int, default=200000, help='Количество записей случайных слов (по умолчанию 200000)')
    
    args = parser.parse_args()
    
    append_random_words('Words.txt', args.n)

if __name__ == "__main__":
    main()
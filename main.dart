import 'dart:async';
import 'dart:io';

// ANSI escape codes
const String clearScreen = "\x1B[2J\x1B[H";
const String hideCursor = "\x1B[?25l";
const String showCursor = "\x1B[?25h";
const String resetCursor = "\x1B[H"; // Posisikan kursor ke (0,0)
const String resetColor = "\x1B[0m"; // Reset ke warna default

// Daftar warna untuk teks
const List<String> textColors = [
  "\x1b[32m", // Hijau
  "\x1b[31m", // Merah
  "\x1b[35m", // Magenta
];

// Kelas Node untuk LinkedList manual
class Node {
  String value;
  String color;
  Node? next;

  Node(this.value, {this.color = resetColor});
}

// Implementasi LinkedList manual
class LinkedList {
  Node? head;

  void insert(Node node) {
    if (head == null) {
      head = node;
    } else {
      Node? current = head;
      while (current?.next != null) {
        current = current?.next;
      }
      current?.next = node;
    }
  }

  Node? first() {
    return head;
  }
}

void main() {
  stdout.write("Masukkan nama mu : ");
  String? inputName = stdin.readLineSync() ?? '';

  // Ukuran terminal
  final int terminalWidth = stdout.terminalColumns;
  final int terminalHeight = stdout.terminalLines;
  final int totalSpace = terminalWidth * terminalHeight;
  final String nameToPrint = inputName.isNotEmpty ? inputName : "USER";

  // Membuat grid dari LinkedList
  final List<LinkedList> grid = List.generate(terminalHeight, (_) {
    final row = LinkedList();
    for (int i = 0; i < terminalWidth; i++) {
      row.insert(Node(' ')); // Isi baris dengan spasi
    }
    return row;
  });

  int position = 0; // Posisi untuk karakter yang akan dicetak
  bool nameFinished = false; // Status apakah nama sudah selesai ditampilkan
  int colorCycle = 0; // Untuk merotasi warna teks

  // Fungsi untuk mencetak grid
  void displayGrid() {
    stdout.write(resetCursor); // Reset posisi kursor ke (0, 0)
    for (var row in grid) {
      Node? currentNode = row.first();
      while (currentNode != null) {
        stdout.write("${currentNode.color}${currentNode.value}"); // Cetak node dengan warna
        currentNode = currentNode.next;
      }
    }
    stdout.write(resetColor); // Reset warna setelah mencetak grid
  }

  // Fungsi animasi
  Future<void> startAnimation() async {
    // Fase 1: Menampilkan nama
    while (position < totalSpace && !nameFinished) {
      int row = (position ~/ terminalWidth) % terminalHeight; // Baris saat ini
      int col = (position % terminalWidth); // Kolom saat ini

      var currentRow = grid[row];
      Node? currentNode = currentRow.first();

      // Akses node tertentu berdasarkan kolom
      for (int i = 0; i < col; i++) {
        currentNode = currentNode?.next;
      }

      // Tentukan arah pergerakan
      if ((row % 2) == 0) {
        // Baris genap: kiri ke kanan
        currentNode?.value = nameToPrint[position % nameToPrint.length];
      } else {
        // Baris ganjil: kanan ke kiri
        int reversedCol = terminalWidth - 1 - col;
        currentNode = currentRow.first();
        for (int i = 0; i < reversedCol; i++) {
          currentNode = currentNode?.next;
        }
        currentNode?.value = nameToPrint[position % nameToPrint.length];
      }

      stdout.write("${hideCursor}"); // Sembunyikan kursor
      displayGrid();
      position++;

      await Future.delayed(Duration(milliseconds: 75)); // Delay sebelum langkah berikutnya

      // Cek apakah nama sudah selesai dicetak
      if (position >= totalSpace) {
        nameFinished = true;
        position = 0; // Reset posisi untuk perubahan warna
      }
    }

    // Fase 2: Merotasi warna teks setelah pencetakan selesai
    while (nameFinished && position < totalSpace && colorCycle < textColors.length) {
      int row = (position ~/ terminalWidth) % terminalHeight;
      int col = (position % terminalWidth);

      var currentRow = grid[row];
      Node? currentNode = currentRow.first();

      for (int i = 0; i < col; i++) {
        currentNode = currentNode?.next;
      }

      if ((row % 2) == 0) {
        // Baris genap: kiri ke kanan
        currentNode?.color = textColors[colorCycle % textColors.length];
      } else {
        // Baris ganjil: kanan ke kiri
        int reversedCol = terminalWidth - 1 - col;
        currentNode = currentRow.first();
        for (int i = 0; i < reversedCol; i++) {
          currentNode = currentNode?.next;
        }
        currentNode?.color = textColors[colorCycle % textColors.length];
      }

      stdout.write("${hideCursor}"); // Sembunyikan kursor
      displayGrid();
      position++;

      await Future.delayed(Duration(milliseconds: 75)); // Delay sebelum langkah berikutnya

      // Ubah warna berulang
      if (position >= totalSpace) {
        colorCycle++; // Ubah warna berikutnya
        position = 0; // Reset posisi untuk siklus selanjutnya
      }
    }

    stdout.write(showCursor); // Tampilkan kursor setelah animasi selesai
  }

  startAnimation();
}

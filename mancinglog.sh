#!/bin/bash
# Ini adalah shebang yang menunjukkan script ini harus dijalankan menggunakan bash

logpath=/var/log/nginx/access.log
# Mendefinisikan path ke file log nginx

ARRAY=()
getip=()
getfile=()
# Menginisialisasi array kosong

function getfiles {
    # Fungsi untuk mendapatkan daftar file yang diakses
    
    echo "getfiles param " ${getip[@]}
    # Menampilkan parameter IP yang diterima
    
    pat=$(echo ${getip[@]}|tr " " "|")
    # Membuat pattern dengan menggabungkan semua IP menggunakan separator "|"
    
    getfile+=($(grep -Ew $pat $logpath| cut -f 7 -d " " | sort | uniq))
    # - Mencari baris log yang mengandung IP sesuai pattern
    # - Mengambil field ke-7 (path file yang diakses)
    # - Mengurutkan dan mengambil nilai unik
    
    uniqf=($(printf "%s\n" "${getfile[@]}" | sort | uniq -c | sort -rnk1 | awk '{ print $2 }'))
    # Mengurutkan file berdasarkan frekuensi akses
    
    unset getfile
    getfile=("${uniqf[@]}")
    # Memperbarui array getfile dengan hasil pengurutan
    
    printf "%s\n" "${getfile[@]}" > files.txt
    # Menyimpan daftar file ke files.txt
    
    echo "getfiles result " ${getfile[@]}
    # Menampilkan hasil
    
    getips
    # Memanggil fungsi getips
}

function getips {
    # Fungsi untuk mendapatkan daftar IP yang mengakses
    
    echo "getips param " ${getfile[@]}
    # Menampilkan parameter file yang diterima
    
    pat=$(echo ${getfile[@]}|tr " " "|")
    # Membuat pattern dengan menggabungkan semua file menggunakan separator "|"
    
    getip+=($(grep -Ew $pat $logpath| cut -f 1 -d " " | sort | uniq))
    # - Mencari baris log yang mengandung path file sesuai pattern
    # - Mengambil field ke-1 (alamat IP)
    # - Mengurutkan dan mengambil nilai unik
    
    uniqi=($(printf "%s\n" "${getip[@]}" | sort | uniq -c | sort -rnk1 | awk '{ print $2 }'))
    # Mengurutkan IP berdasarkan frekuensi akses
    
    unset getip
    getip=("${uniqi[@]}")
    # Memperbarui array getip dengan hasil pengurutan
    
    printf "%s\n" "${getip[@]}" > ips.txt
    # Menyimpan daftar IP ke ips.txt
    
    echo "getips result "${getip[@]}
    # Menampilkan hasil
    
    getfiles
    # Memanggil fungsi getfiles
}

# Program utama
getfile=( `cat "files.txt"` )
getip=( `cat "ips.txt"` )
# Membaca data awal dari files.txt dan ips.txt

getfile+=($1)
# Menambahkan parameter pertama ke array getfile

getips
# Memulai proses dengan memanggil fungsi getips

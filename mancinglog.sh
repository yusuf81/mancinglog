#!/bin/bash

# Path ke log nginx
logpath=/var/log/nginx/access.log

# Inisialisasi array
ARRAY=()
getip=()
getfile=()

function getfiles {
    # Simpan state sebelumnya untuk deteksi konvergen
    old_files=(${getfile[@]})
    
    echo "==== getfiles() ===="
    echo "Input IPs: " ${getip[@]}
    
    # Buat pattern untuk grep dengan menggabungkan semua IP
    pat=$(echo ${getip[@]}|tr " " "|")
    
    # Cari semua file yang diakses oleh IP-IP tersebut
    getfile+=($(grep -Ew $pat $logpath| cut -f 7 -d " " | sort | uniq))
    
    # Urutkan file berdasarkan frekuensi akses dan ambil yang unik
    uniqf=($(printf "%s\n" "${getfile[@]}" | sort | uniq -c | sort -rnk1 | awk '{ print $2 }'))
    
    # Reset dan update array getfile
    unset getfile
    getfile=("${uniqf[@]}")
    
    # Simpan ke file untuk referensi
    printf "%s\n" "${getfile[@]}" > files.txt
    
    echo "Files found: " ${getfile[@]}
    
    # Cek apakah sudah konvergen
    if [[ "${old_files[*]}" == "${getfile[*]}" ]]; then
        echo "========================================="
        echo "Converged! No new files found."
        echo "Final list of suspicious IPs:"
        printf '%s\n' "${getip[@]}"
        echo "Final list of accessed files:"
        printf '%s\n' "${getfile[@]}"
        echo "========================================="
        exit 0
    fi
    
    # Jika belum konvergen, lanjut ke fungsi getips
    getips
}

function getips {
    # Simpan state sebelumnya untuk deteksi konvergen
    old_ips=(${getip[@]})
    
    echo "==== getips() ===="
    echo "Input files: " ${getfile[@]}
    
    # Buat pattern untuk grep dengan menggabungkan semua file
    pat=$(echo ${getfile[@]}|tr " " "|")
    
    # Cari semua IP yang mengakses file-file tersebut
    getip+=($(grep -Ew $pat $logpath| cut -f 1 -d " " | sort | uniq))
    
    # Urutkan IP berdasarkan frekuensi akses dan ambil yang unik
    uniqi=($(printf "%s\n" "${getip[@]}" | sort | uniq -c | sort -rnk1 | awk '{ print $2 }'))
    
    # Reset dan update array getip
    unset getip
    getip=("${uniqi[@]}")
    
    # Simpan ke file untuk referensi
    printf "%s\n" "${getip[@]}" > ips.txt
    
    echo "IPs found: "${getip[@]}
    
    # Cek apakah sudah konvergen
    if [[ "${old_ips[*]}" == "${getip[*]}" ]]; then
        echo "========================================="
        echo "Converged! No new IPs found."
        echo "Final list of suspicious IPs:"
        printf '%s\n' "${getip[@]}"
        echo "Final list of accessed files:"
        printf '%s\n' "${getfile[@]}"
        echo "========================================="
        exit 0
    fi
    
    # Jika belum konvergen, lanjut ke fungsi getfiles
    getfiles
}

# Main program
echo "Starting cross-correlation analysis..."
echo "========================================="

# Baca data awal jika ada
if [ -f "files.txt" ]; then
    getfile=( `cat "files.txt"` )
    echo "Loaded initial files: " ${getfile[@]}
fi

if [ -f "ips.txt" ]; then
    getip=( `cat "ips.txt"` )
    echo "Loaded initial IPs: " ${getip[@]}
fi

# Cek apakah ada parameter file yang diberikan
if [ -n "$1" ]; then
    echo "Starting analysis with file: $1"
    getfile+=($1)
else
    echo "Usage: $0 <suspicious_file_path>"
    echo "Example: $0 /wp-admin.php"
    exit 1
fi

# Mulai analisis
getips

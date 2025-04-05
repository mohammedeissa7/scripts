#!/bin/bash

# GlobaL Values
DB_DIR="database"
CURRENT_DB=""


function main_menu {
    clear
    echo "Welcome to the Simple Database Manager!"
    echo "1. Create a new database"
    echo "2. List databases "
    echo "3. connect to database"
    echo "4. Drop Database"
    echo "5. Exit"

    read -p "Enter Your Choice : " choice
    echo ""
    case $choice in
    1) create_database ;;
    2) list_databases ;;
    3) connect_database ;;
    4) drop_database ;;
    5) exit 0 ;;
    *) echo "Invalid Option"; sleep 1 ; main_menu ;;
    esac
}



function create_database {
    clear
    echo ""
    echo "Creating database"
    echo ""
    read -p "Enter Database Name : " dbname
    
    # This checks if $dbname is not a valid name
    if [[ ! "$dbname"=~ ^[a-zA-Z][a-zA-Z0-9_]*$  ]]; then
        echo "Invalid Database Name"
        sleep 1
        main_menu
        return
    fi 
    # This checks if $dbname Exist or NOT
    if [-d "$DB_DIR/$dbname"] ; then
        echo " Database '$dbname' is already exist " 
    else
        mkdir -p "$DB_DIR/$dbname"
        echo " Database '$dbname' is created succesfully "
    fi 
    sleep 1
    main_menu

}

function list_databases {
    clear
    echo ""
    echo "List all Databases  :"
    echo ""
    if [! -d  "$DB_DIR"] || [-z "$(ls -A "$DB_DIR")"]; then
        echo "No Database Exist"
    else 
        echo "$(ls -A "$DB_DIR")"
    fi

    sleep 1
    
    main_menu
}

function connect_to_database {
    clear
    echo ""
    echo "Connecet To Database"
    echo ""
    if [ ! -d "$DB_DIR" ] || [ -z "$(ls -A $DB_DIR)" ]; then
        echo "No databases exist."
        sleep 2
        main_menu
        return
    fi
        
    echo "Available databases:"
    ls "$DB_DIR"
    echo ""
    read -p "Enter The Database You Want to Connect" dbname

    if [-d "$DB_DIR/$dbname"] ; then
        CURRENT_DB="$dbname"
        sleep 1
        table_menu
    else
        echo "Database '$dbname' is Not Exist"
        sleep 1 
        main_menu
    fi 



}

function Drop_Database {
    clear
    echo ""
    echo "Drop Database"
    echo ""
    if [ ! -d "$DB_DIR" ] || [ -z "$(ls -A $DB_DIR)" ]; then
        echo "No databases exist."
        main_menu
        return
    fi
            
    echo "Available databases:"
    ls "$DB_DIR"
    echo ""
    read -p "Enter The Database You Want to Connect" dbname

    if [-d "$DB_DIR/$dbname"]; then
        rm -r "$DB_DIR/$dbname"
        echo "Database Dropped Succesfully"
        if ["$CURRENT_DB" == "$dbname" ]; then
            CURRENT_DB=""
        fi
    else
        echo "Database '$dbname' does not exist."
    fi
    main_menu

}


function table_menu {
    echo ""
    echo "| Database: $CURRENT_DB"
    echo "| Table Menu                    |"
    echo "---------------------------------"
    echo "| 1. Create Table               |"
    echo "| 2. List Tables                |"
    echo "| 3. Drop Table                 |"
    echo "| 4. Insert into Table          |"
    echo "| 5. Select From Table          |"
    echo "| 6. Delete From Table          |"
    echo "| 7. Update Table               |"
    echo "| 8. Back to Main Menu          |"
    echo ""

        
    read -p "Enter your choice: " choice
    case $choice in
        1) create_table ;;
        2) list_tables ;;
        3) drop_table ;;
        4) insert_into_table ;;
        5) select_from_table ;;
        6) delete_from_table ;;
        7) update_table ;;
        8) CURRENT_DB=""; main_menu ;;
        *) echo "Invalid option"; sleep 1; table_menu ;;
    esac
}


function Create_Table{
    clear
    echo ""
    echo "Create Table"
    echo ""
    read -p "Please Enter Table Name" tablename

    if [[! "$tablename"=~ ^[a-zA-Z][a-zA-Z0-9_]*$  ]]; then
        echo "Invalid Table Name"
        table_menu
        return
    fi

    local tablepath="$DB_DIR/$CURRENT_DB/tablename"
    local metapath="$DB_DIR/$CURRENT_DB/.$tablename.meta"

    if [-f "$tablename"]; then 
        echo "The '$tablename' done succesfully"
        table_menu
        return
    fi
    touch "$tablepath"
    touch "$metapath"

        
    echo "Enter column definitions (one per line). Format: column_name datatype [primary_key]"
    echo "Supported datatypes: int, str, bool"
    echo "Enter 'done' when finished."
    
    local columns=()
    local datatypes=() 
    local primary_key=""
    local has_primary=false

    while true; do
        read -p "Coulumn Definition: " coldef
        if [ "$coldef" == "done" ]; then
            break
        fi
        
        local columns=$(echo "$coldef"| awk '{print $1}') 
        local coltype=$(echo "$coldef"| awk '{print $2}')
        local is_primary=$(echo "$coldef"| awk '{print $3}')
        
        if [[ ! "$colname" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
            echo "Invalid column name. Must start with letter or underscore and contain only letters, numbers and underscores."
            continue
        fi

        if [[! "$coltype"=~ ^(int|str|bool)$ ]]; then
            echo "Invalid datatype. Must be one of: int, str, bool"
            continue
        fi

        if [ ! -z "$is_primary"]; then
            if [ "$is_primary" != "primary_key" ]; then
                echo "Invalid primary key specification. Use 'primary_key' or leave blank."
                continue
            fi
            
            if [ "$has_primary" = true ]; then
                echo "Only one primary key is allowed per table."
                continue
            fi
            
            primary_key="$colname"
            has_primary=true
        fi

        columns+=("$colname")
        datatype+=("$coltype")
        echo "Column '$colname' added."
    done
    if [${colmns[@]} -eq 0 ]; then
        echo ""
        rm "$tablepath"
        rm "$metapath"
        table_menu
        return
    fi        

    if ["$has_primary" = false]; then
        primary_key="${columns[0]}"
        echo "No primary key specified. Using first column '$primary_key' as primary key."
    
    fi

    echo "columns:${columns[*]}" > "$metapath"
    echo "datatypes:${datatypes[*]}" >> "$metapath"
    echo "primary_key:$primary_key" >> "$metapath"
    
    echo "Table '$tablename' created successfully with columns: '${columns[*]}' "
    echo "Primary key: '$primary_key' "

    table_menu

}     
function List_Tables{
    clear
    echo ""
    echo "List Of Tables in '$CURRENT_DB' : "
    echo ""

    local tables=$(ls "$DB_DIR/$CURRENT_DB" | grep -v '^\.')

    if [-z "$tables"]; then
        echo "There is no database"
    else
        echo "Tables : "
        for table in $tables; do
            if [[ "$table" != .* ]]; then
                echo "- $table"
            fi
        done
    
    fi

    read -p "press any key to go to table menu"
    table_menu

}    
function Drop_Table{
    clear
    echo ""
    echo "Drop Table"
    echo ""
    local tables=$(ls "$DB_DIR/$CURRENT_DB" | grep -v '^\.')
    
    if [ -z "$tables" ]; then
        echo "No tables exist in this database."

        table_menu
        return
    fi
    
    echo "Available tables:"
    for table in $tables; do
        if [[ "$table" != .* ]]; then
            echo "- $table"
        fi
    done
    echo ""
    
    read -p "Enter table name to drop: " tablename
    
    local tablepath="$DB_DIR/$CURRENT_DB/$tablename"
    local metapath="$DB_DIR/$CURRENT_DB/.$tablename.meta"
    
    if [ -f "$tablepath" ]; then
        rm "$tablepath"
        rm "$metapath"
        echo "Table '$tablename' dropped successfully."
    else
        echo "Table '$tablename' does not exist."
    fi

    table_menu
}   
function Insert_into_Table{
    clear
    echo ""
    echo "Insert into Table"
    echo ""
    
    local tables=$(ls "$DB_DIR/$CURRENT_DB" | grep -v '^\.')
    
    if [ -z "$tables" ]; then
        echo "No tables exist in this database."
        sleep 2
        table_menu
        return
    fi
    
    echo "Available tables:"
    for table in $tables; do
        if [[ "$table" != .* ]]; then
            echo "- $table"
        fi
    done
    echo ""
    
    read -p "Enter table name: " tablename
    
    local tablepath="$DB_DIR/$CURRENT_DB/$tablename"
    local metapath="$DB_DIR/$CURRENT_DB/.$tablename.meta"
    
    if [ ! -f "$tablepath" ]; then
        echo "Table '$tablename' does not exist."
        sleep 2
        table_menu
        return
    fi


    local columns_line=$(grep "^columns:" "$metapath")
    local datatypes_line=$(grep "^datatypes:" "$metapath")
    local primary_key_line=$(grep "^primary_key:" "$metapath")
    
    local columns=(${columns_line#columns:})
    local datatypes=(${datatypes_line#datatypes:})
    local primary_key=${primary_key_line#primary_key:}
    

    local pk_index=-1

    for i in "${!columns[@]}"; do
        if [ "${columns[i]}" == "$primary_key" ]; then
            pk_index=$i
            break
        fi
    done
    
    echo "Inserting into table '$tablename' with columns: ${columns[*]}"
    echo "Data types: ${datatypes[*]}"
    echo "Primary key: $primary_key"
    echo ""
    
    local values=()
    for i in "${!columns[@]}"; do
        while true; do
            read -p "Enter value for ${columns[i]} (${datatypes[i]}): " value
            
            
            case "${datatypes[i]}" in
                "int")
                    if [[ ! "$value" =~ ^-?[0-9]+$ ]]; then
                        echo "Invalid integer value. Please enter a valid integer."
                        continue
                    fi
                    ;;
                "bool")
                    if [[ ! "$value" =~ ^(true|false)$ ]]; then
                        echo "Invalid boolean value. Must be 'true' or 'false'."
                        continue
                    fi
                    ;;
                "str")
                    
                    ;;
            esac
            
            
            if [ $i -eq $pk_index ]; then
                if grep -q "^$value|" "$tablepath"; then
                    echo "Primary key value '$value' already exists. Must be unique."
                    continue
                fi
            fi
            
            values+=("$value")
            break
        done
    done
    
    
    echo "${values[*]}" | tr ' ' '|' >> "$tablepath"
    
    echo "Record inserted successfully."

    table_menu
}    
function Select_From_Table{
    clear
    echo ""
    echo "Select from Table"
    echo ""
    
    local tables=$(ls "$DB_DIR/$CURRENT_DB" | grep -v '^\.')
    
    if [ -z "$tables" ]; then
        echo "No tables exist in this database."
        sleep 2
        table_menu
        return
    fi
    
    echo "Available tables:"
    for table in $tables; do
        if [[ "$table" != .* ]]; then
            echo "- $table"
        fi
    done
    echo ""
    
    read -p "Enter table name: " tablename
    
    local tablepath="$DB_DIR/$CURRENT_DB/$tablename"
    local metapath="$DB_DIR/$CURRENT_DB/.$tablename.meta"
    
    if [ ! -f "$tablepath" ]; then
        echo "Table '$tablename' does not exist."
        sleep 2
        table_menu
        return
    fi
    

    local columns_line=$(grep "^columns:" "$metapath")
    local datatypes_line=$(grep "^datatypes:" "$metapath")
    local primary_key_line=$(grep "^primary_key:" "$metapath")
    
    local columns=(${columns_line#columns:})
    local datatypes=(${datatypes_line#datatypes:})
    local primary_key=${primary_key_line#primary_key:}
    

    echo ""
    echo "Records in table '$tablename':"
    echo ""
    

    printf "%-20s" "${columns[@]}"
    printf "\n"
    printf "%-20s" "${datatypes[@]}"
    printf "\n"
    
    while IFS='|' read -ra record; do
        printf "%-20s" "${record[@]}"
        printf "\n"
    done < "$tablepath"
    
    read -p "Press any key to return to table menu..."
    table_menu
}    
function Delete_From_Table{
    clear
    echo ""
    echo "Delete from Table"
    echo ""
    
    local tables=$(ls "$DB_DIR/$CURRENT_DB" | grep -v '^\.')
    
    if [ -z "$tables" ]; then
        echo "No tables exist in this database."
        sleep 2
        table_menu
        return
    fi
    
    echo "Available tables:"
    for table in $tables; do
        if [[ "$table" != .* ]]; then
            echo "- $table"
        fi
    done
    echo ""
    
    read -p "Enter table name: " tablename
    
    local tablepath="$DB_DIR/$CURRENT_DB/$tablename"
    local metapath="$DB_DIR/$CURRENT_DB/.$tablename.meta"
    
    if [ ! -f "$tablepath" ]; then
        echo "Table '$tablename' does not exist."
        sleep 2
        table_menu
        return
    fi
    
    local primary_key_line=$(grep "^primary_key:" "$metapath")
    local primary_key=${primary_key_line#primary_key:}
    
    echo ""
    echo "Current records in table '$tablename':"
    echo ""
    
    local columns_line=$(grep "^columns:" "$metapath")
    local columns=(${columns_line#columns:})
    printf "%-20s" "${columns[@]}"
    printf "\n"
    echo ""
    
    local line_num=1
    while IFS='|' read -ra record; do
        printf "%-5s" "$line_num"
        printf "%-15s" "${record[@]}"
        printf "\n"
        ((line_num++))
    done < "$tablepath"
    
    echo ""
    read -p "Enter line number to delete (or 'all' to delete all records): " choice
    
    if [ "$choice" == "all" ]; then
        > "$tablepath"  
        echo "All records deleted from table '$tablename'."
    elif [[ "$choice" =~ ^[0-9]+$ ]]; then
        if [ "$choice" -ge 1 ] && [ "$choice" -lt $line_num ]; then
            
            sed -i "${choice}d" "$tablepath"
            echo "Record $choice deleted successfully."
        else
            echo "Invalid line number."
        fi
    else
        echo "Invalid input."
    fi
    
    sleep 2
    table_menu
}    
function Update_Table{
    clear
    echo ""
    echo "Update Table"
    echo ""
    
    local tables=$(ls "$DB_DIR/$CURRENT_DB" | grep -v '^\.')
    
    if [ -z "$tables" ]; then
        echo "No tables exist in this database."
        sleep 2
        table_menu
        return
    fi
    
    echo "Available tables:"
    for table in $tables; do
        if [[ "$table" != .* ]]; then
            echo "- $table"
        fi
    done
    echo ""
    
    read -p "Enter table name: " tablename
    
    local tablepath="$DB_DIR/$CURRENT_DB/$tablename"
    local metapath="$DB_DIR/$CURRENT_DB/.$tablename.meta"
    
    if [ ! -f "$tablepath" ]; then
        echo "Table '$tablename' does not exist."
        sleep 2
        table_menu
        return
    fi
    
    local columns_line=$(grep "^columns:" "$metapath")
    local datatypes_line=$(grep "^datatypes:" "$metapath")
    local primary_key_line=$(grep "^primary_key:" "$metapath")
    
    local columns=(${columns_line#columns:})
    local datatypes=(${datatypes_line#datatypes:})
    local primary_key=${primary_key_line#primary_key:}
    
    local pk_index=-1
    for i in "${!columns[@]}"; do
        if [ "${columns[i]}" == "$primary_key" ]; then
            pk_index=$i
            break
        fi
    done
    
    echo ""
    echo "Current records in table '$tablename':"
    echo ""
    
    printf "%-5s" "Line"
    printf "%-20s" "${columns[@]}"
    printf "\n"
    echo ""
    
    local line_num=1
    while IFS='|' read -ra record; do
        printf "%-5s" "$line_num"
        printf "%-20s" "${record[@]}"
        printf "\n"
        ((line_num++))
    done < "$tablepath"
    
    echo ""
    read -p "Enter line number to update: " line_num
    
    if [[ ! "$line_num" =~ ^[0-9]+$ ]] || [ "$line_num" -lt 1 ] || [ "$line_num" -ge $line_num ]; then
        echo "Invalid line number."
        sleep 2
        table_menu
        return
    fi
    
    local record=()
    IFS='|' read -ra record < <(sed -n "${line_num}p" "$tablepath")
    
    echo ""
    echo "Updating record:"
    for i in "${!columns[@]}"; do
        echo "${columns[i]} (${datatypes[i]}): ${record[i]}"
    done
    echo ""
    
    local tempfile=$(mktemp)
    
    local current_line=1
    while IFS= read -r line; do
        if [ "$current_line" -eq "$line_num" ]; then
            local new_record=()
            for i in "${!columns[@]}"; do
                while true; do
                    read -p "Enter new value for ${columns[i]} (${datatypes[i]}) [current: ${record[i]}]: " value
                    
                    if [ -z "$value" ]; then
                        value="${record[i]}"
                        break
                    fi
                    
                  
                    case "${datatypes[i]}" in
                        "int")
                            if [[ ! "$value" =~ ^-?[0-9]+$ ]]; then
                                echo "Invalid integer value. Please enter a valid integer."
                                continue
                            fi
                            ;;
                        "bool")
                            if [[ ! "$value" =~ ^(true|false)$ ]]; then
                                echo "Invalid boolean value. Must be 'true' or 'false'."
                                continue
                            fi
                            ;;
                        "str")

                            ;;
                    esac
                    

                    if [ $i -eq $pk_index ] && [ "$value" != "${record[i]}" ]; then
                        if grep -q "^$value|" "$tablepath"; then
                            echo "Primary key value '$value' already exists. Must be unique."
                            continue
                        fi
                    fi
                    
                    break
                done
                new_record+=("$value")
            done
            
            echo "$(IFS='|'; echo "${new_record[*]}")" >> "$tempfile"
        else
            echo "$line" >> "$tempfile"
        fi
        ((current_line++))
    done < "$tablepath"
    
    mv "$tempfile" "$tablepath"
    
    echo "Record updated successfully."
    sleep 2
    table_menu
}     


mkdir -i "$DB_DIR"

main_menu




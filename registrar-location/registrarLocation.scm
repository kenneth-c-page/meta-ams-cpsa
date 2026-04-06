(herald "Meta-AMS (MAMS) Registrar Location, Precursor to Module Registration")

(defprotocol mams_reg_location basic
    (defrole new_mod
        (send
            registrar_query
                header
                    venture number
                    unit number
                    role number
                    ref number (query number)
                signature
                supp data
                    MAMS endpoint name  
        )
        (recv
            cell_spec
                header
                    venture 0
                    unit    0
                    role    0
                    ref (echo)
                signature
                supp data
                    cell descriptor
                    unit
                    endpoint name
        )
    )
    (defrole config_server_known
        (recv
            registrar_query
        )
        (load
            unit
            endpoint name
        )
        (send
            cell_spec
        )
    )
    (defrole new_mod
        (send
            registrar_query
        )
        (recv
            registrar_unknown
                header
                    venture 0
                    unit    0
                    role    0
                    ref (echo)
                signature
                supp data
                    none
        )
    )
    (defrole config_server_unknown
        (recv
            registrar_query
        )
        (send
            registrar_unknown
        )
    )
)
(herald "Meta-AMS (MAMS) Registrar Registration")

(defprotocol mams_registrar_reg basic
    (defrole new_registrar
        (vars
            (n1 text) (unit_number reg_role_number reg_ref_number text) (announce_registrar text) (app name) (reg_mib locn)
            (n2 text) (conf_role_number conf_ref_number text) (registrar_noted text) (cont name)
            (n3 text) (cell_spec_body mesg)
        )
        (trace
            ; announce_registrar
            (send
                (cat
                    ; mpdu header, per 5.1.1
                    (mpdu_header
                        unit_number
                        reg_role_number
                        reg_ref_number
                    )
                    ; mpdu digital signature, per 5.1.4
                    ; app private key used to sign, per 5.1.4.3
                    (cat
                        n1
                        (enc
                            n1
                            "known_string"
                            (privk app)
                        )
                    )
                    ; per 5.1.5.x, supplementary data includes:
                    ; endpoint name (useful since this will be stored and loaded), cell descriptor, module list
                    ; assigned module number, delivery point name, delivery vector, delivery vector list,
                    ; contact summary, subscription assertion structure, invitation assertion structure,
                    ; subscription list, invitation list, declaration structure, module status structure,
                    ; module status list, subscription cancellation structure, invitation cancellation structure,
                    ; reconnect structure, and refusal reason
                    ; HOWEVER, only some of these are relevant to the registrar's announce_registrar MPDU
                    announce_registrar
                )
            )
            ; registrar_noted
            (recv
                (cat
                    (mpdu_header
                        unit_number
                        conf_role_number
                        conf_ref_number
                    )
                    (cat
                        n2
                        (enc
                            n2
                            "known_string"
                            (privk cont)
                        )
                    )
                    registrar_noted
                )
            )
            ; cell_spec
            (recv
                (cat
                    (mpdu_header
                        unit_number
                        conf_role_number
                        conf_ref_number
                    )
                    (cat
                        n3
                        (enc
                            n3
                            "known_string"
                            (privk cont)
                        )
                    )
                    cell_spec_body
                )
            )
            ; store cell_spec
            (stor
                reg_mib
                cell_spec_body
            )
        )
    )
    (defrole config_server
        (vars
            (n0 text) (app1 name)
            (foreign_role_numbers foreign_ref_numbers text)
            (n1 unit_number reg_role_number reg_ref_number text) (announce_registrar text) (app name) (conf_mib locn)
            (n2 conf_role_number conf_ref_number text) (registrar_noted text) (cont name)
            (n3 text) (cell_spec_body mesg)
            (n4 text)
        )
        (trace
            ; foreign_registrars heartbeat
            (recv
                (cat
                    (mpdu_header
                        unit_number
                        foreign_role_numbers
                        foreign_ref_numbers
                    )
                    (cat
                        n0
                        (enc
                            n0
                            "known_string"
                            (privk app1)
                        )
                    )
                )
            )
            ; announce_registrar
            (recv
                (cat
                    (mpdu_header
                        unit_number
                        reg_role_number
                        reg_ref_number
                    )
                    (cat
                        n1
                        (enc
                            n1
                            "known_string"
                            (privk app)
                        )
                    )
                    announce_registrar
                )
            )
            ; store supplementary data (registrar location) in mib
            (stor
                conf_mib
                announce_registrar
            )
            ; registrar_noted
            (send
                (cat
                    (mpdu_header
                        unit_number
                        conf_role_number
                        conf_ref_number
                    )
                    (cat
                        n2
                        (enc
                            n2
                            "known_string"
                            (privk cont)
                        )
                    )
                    registrar_noted
                )
            )
            ; load cell_spec_body
            (load
                conf_mib
                cell_spec_body
            )
            ; cell_spec
            (send
                (cat
                    (mpdu_header
                        unit_number
                        conf_role_number
                        conf_ref_number
                    )
                    (cat
                        n3
                        (enc
                            n3
                            "known_string"
                            (privk cont)
                        )
                    )
                    cell_spec_body
                )
            )
            ; cell_spec to foreign_registrars
            (send
                (cat
                    (mpdu_header
                        unit_number
                        conf_role_number
                        conf_ref_number
                    )
                    (cat
                        n4
                        (enc
                            n4
                            "known_string"
                            (privk cont)
                        )
                    )
                    cell_spec_body
                )
            )
        )
    )
    (defrole foreign_registrars
        (vars
            (n0 text) (app1 name)
            (foreign_role_numbers foreign_ref_numbers text)
            (unit_number conf_role_number conf_ref_number text) (cont name) (foreign_reg_mib locn)
            (n4 text) (cell_spec_body mesg)
        )
        (trace
            ; heartbeat
            (send
                (cat
                    (mpdu_header
                        unit_number
                        foreign_role_numbers
                        foreign_ref_numbers
                    )
                    (cat
                        n0
                        (enc
                            n0
                            "known_string"
                            (privk app1)
                        )
                    )
                )
            )
            ; cell_spec
            (recv
                (cat
                    (mpdu_header
                        unit_number
                        conf_role_number
                        conf_ref_number
                    )
                    (cat
                        n4
                        (enc
                            n4
                            "known_string"
                            (privk cont)
                        )
                    )
                    cell_spec_body
                )
            )
            ; store cell_spec
            (stor
                foreign_reg_mib
                cell_spec_body
            )
        )
    )
    (lang
        (mpdu_header (tuple 3))
    )
)

; ========== registrar_noted ========== ;
(defskeleton mams_registrar_reg
    (vars
        (n0 text) (foreign_role_numbers foreign_ref_numbers text) (app1 name) 
        (n1 text) (unit_number reg_role_number reg_ref_number text) (announce_registrar text) (app name) (reg_mib conf_mib locn)
        (n2 text) (conf_role_number conf_ref_number text) (registrar_noted text) (cont name)
        (n3 text) (cell_spec_body mesg)
        (n4 text) (foreign_reg_mib locn)
    )
    (defstrandmax new_registrar
        (unit_number unit_number) (reg_role_number reg_role_number) (reg_ref_number reg_ref_number) ; header
        (n1 n1) (app app) (announce_registrar announce_registrar)                                   ; signature and payload
        (reg_mib reg_mib)
        (conf_role_number conf_role_number) (conf_ref_number conf_ref_number)
        (n2 n2) (cont cont) (registrar_noted registrar_noted)
        (n3 n3) (cell_spec_body cell_spec_body)
    )
    (non-orig (privk app))
    (non-orig (privk cont))
    (uniq-orig n1)
)
(defskeleton mams_registrar_reg
    (vars
        (n0 text) (foreign_role_numbers foreign_ref_numbers text) (app1 name) 
        (n1 text) (unit_number reg_role_number reg_ref_number text) (announce_registrar text) (app name) (reg_mib conf_mib locn)
        (n2 text) (conf_role_number conf_ref_number text) (registrar_noted text) (cont name)
        (n3 text) (cell_spec_body mesg)
        (n4 text) (foreign_reg_mib locn)
    )
    (defstrandmax config_server
        (n0 n0) (app1 app1)
        (foreign_role_numbers foreign_role_numbers) (foreign_ref_numbers foreign_ref_numbers)
        (unit_number unit_number) (reg_role_number reg_role_number) (reg_ref_number reg_ref_number) ; header
        (n1 n1) (app app) (announce_registrar announce_registrar)                                   ; signature and payload
        (conf_mib conf_mib)
        (conf_role_number conf_role_number) (conf_ref_number conf_ref_number)
        (n2 n2) (cont cont) (registrar_noted registrar_noted)
        (n3 n3) (cell_spec_body cell_spec_body)
        (n4 n4)
    )
    (non-orig (privk app1))
    (non-orig (privk cont))
    (non-orig (privk app))
    (uniq-orig n2)
    (uniq-orig n3)
    (uniq-orig n4)
)
(defskeleton mams_registrar_reg
    (vars
        (n0 text) (foreign_role_numbers foreign_ref_numbers text) (app1 name) 
        (n1 text) (unit_number reg_role_number reg_ref_number text) (announce_registrar text) (app name) (reg_mib conf_mib locn)
        (n2 text) (conf_role_number conf_ref_number text) (registrar_noted text) (cont name)
        (n3 text) (cell_spec_body mesg)
        (n4 text) (foreign_reg_mib locn)
    )
    (defstrandmax foreign_registrars
        (n0 n0) (app1 app1)
        (foreign_role_numbers foreign_role_numbers) (foreign_ref_numbers foreign_ref_numbers)
        (unit_number unit_number) (conf_role_number conf_role_number) (conf_ref_number conf_ref_number) (cont cont) (foreign_reg_mib foreign_reg_mib)
        (n4 n4) (cell_spec_body cell_spec_body)
    )
    (non-orig (privk app1))
    (non-orig (privk cont))
    (uniq-orig n0)
)
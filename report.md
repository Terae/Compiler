---
title: Projet Systèmes Informatiques
author: Benjamin BIGEY,
author: Jérôme M M KOMPÉ
affiliation: Institut National des Sciences Appliquées, Toulouse
---

# Réalisation du compilateur C

## Grammaire considérée

Lors de l'implémentation de notre compilateur, nous avons choisi une grammaire plus riche que la version simplifiée qui nous a été proposée. Voici la liste des fonctionnalités offertes dans notre grammaire :

* Le programme est composé d'une liste de variables globales et de définitions de fonctions
* Les fonctions doivent avoir leur corps défini en même temps que leur déclaration
* Les types reconnus sont `int`, `void`, `char` et `bool`
* Les types peuvent être agrémentés de qualificateurs (`const`) et peuvent être des indirections ; le type suivant est par exemple reconnu : `const * * const * int`
* Les entiers peuvent être reconnus sous la forme décimale, octo-décimale, hexa-décimale ou exponentielle
* Les opérateurs unaires, logiques, de décallage, d'opérations, de condition binaire et ternaire, d'affectation et `sizeof` sont tous reconnus
* Les `string`s litéraux sont reconnus mais ramenés à un unique caractère
* Les expressions peuvent être enchaînées et leur résolution correspond aux [priorités du langage C](https://en.cppreference.com/w/c/language/operator_precedence)
* Les opérations arithmétiques `+`, `-`, `++`, `%=` etc. ont été correctement gérées et sont cohérentes avec les variables
* Les expressions conditionnelles `if / else` et `while` sont opérationnelles
* Les fonctions `void printf(int)` et `void scanf(*int)` sont reconnues et traitées par l'assembleur
* Les variables globales sont permises
* Les commentaires sur une ligne ou par blocs sont traités

## Génération du code assembleur

Notre implémentation actuelle ne prend pas en compte les pointeurs, les `string`s ni les opérateurs 'bitwise'. Cependant, la génération du code assembleur est opérationnelle pour le reste de la grammaire considérée, et on a modifié le jeu d'instructions pour supprimer les instructions `INFE`, `SUP` et `SUPE` car elles peuvent toutes découler de l'instruction `INF`.

On a également inséré les quatre instructions suivantes :

    Opération     | Code |  OP   | A  | B | C |       Description       | VHDL
------------------|------|-------|----|---|---|-------------------------|-----
Printf            | 0x0B | PRINT | @i | - | - | printf("%d", \*i)       | non
Scanf             | 0x0C | SCANF | Ri | - | - | [Ri] <- scanf()         | non
Saut par registre | 0x0D | JMPR  | Ri | - | - | Saut à l'adresse [Ri]   | oui
NOP               | 0x90 | NOP   | -  | - | - | Temporisation d'une instruction | oui

Mise à part l'instruction `NOP` qui n'est utilisée que dans le processeur pour la gestion des aléas, l'ensemble des instructions peuvent être codées sur 4 bits (de `0x00` à `0x0F`).

## Utilisation des registres

Notre processeur utilise 16 registres, mais tous ne sont pas utilisés.

Nous utilisons  registres pour accomplir l'ensemble des opérations :

0. `R0`, un registre utilisable par un développeur avec sauvegarde du contexte
1. `R1`, un registre utilisable par un développeur avec sauvegarde du contexte
2. `R2`, un registre utilisable par un développeur avec sauvegarde du contexte
3. `ESP`, qui permets d'associer relativement une plage de mémoire à chaque fonction
4. `tmpR`, un registre sans sauvegarde du contexte qui est utilisé comme zone mémoire temporaire pour réaliser certaines opérations sans compromettre le contexte des autres registres
5. `retR`, un registre qui permets de contenir le résultat de retour de la fonction appelée

## L'interpréteur
L'interpréteur demandé pour le projet a également été réalisé, ce qui s'est avéré indispensable pour tester et corriger la génération de code.

Il est capable de lire du code assembleur sous forme de texte avec des commentaires : `ADD 3, 10 ; increases ebp`

# Microprocesseur
La seconde partie du projet consiste en la réalisation d'un microprocesseur de type RISC avec 4 niveaux de pipeline.

Nous avons utilisé le langage de description VHDL pour le réaliser sur une carte FPGA de type Spartan.

Le compilateur et le processeur que nous avons réalisés sont compatibles et orientés registres, même si nous n'avons pas eu le temps d'exécuter des instructions en réel sur la carte FPGA et donc l'ensemble de la chaîne de l'écriture d'un code C à son exécution par le microprocesseur n'a pas pu être validée.

## Démarche globale
Comme conseillé, nous avons réalisé notre microprocesseur par étapes. Dans un premier temps, nous avons développé individuellement chaque composant. Ensuite, après les avoir testé, nous les avons intégré ensemble en nous inspirant du schéma de conception du processeur.

Nous avons pu tester en simulation l'ensemble des instructions et l'ensemble du processeur nous semble valide.

## Les choix d'implémentation
Sachant que chaque pipeline du chemin de données sont synchrones, nous avons privilégié un développement asynchrone pour chaque composant pour minimiser la temporisation. Ainsi, seuls le compteur IP, la gestion des aléas et les écritures en mémoire sont synchrones.

Nous avons fait le choix de créer un module distinct pour chaque composant pour gagner en lisibilité lors de la phase de test. De plus, ce choix nous a permis de pouvoir instantier plusieurs fois un même module.

## Processeur final

Les instructions suivantes sont toutes prises en charge : `AFC`, `COP`, `ADD`, `SUB`, `MUL`, `LOAD`, `STORE`, `JMP`, `JMPR`, `JMPC`, `NOP`

Un composant nommé `Computer` permets de superviser l'ensemble du comportement du processeur. Il s'occupe de la gestion de la clock et de la RAM, et les interface avec le `Processor`.

Ce dernier possède plusieurs composants qu'il câble comme il faut en suivant le schéma de la gestion des données fourni lors du cahier des charges, à savoir l'`ALU`, le `Decode`r, le `RegistersFile`, l'`InstrMemory`, 4 niveaux de `Pipeline`, l'`AleaSupervisor` et l'`IP`.

Les `Pipeline`s sont considérées comme un unique composant, ce qui permets d'être plus généralistes. Pour les étages 3 et 4, ils ne prennenent pas en compte l'entrée C et donc on a câblé la dernière entrée sur `open` en sortie et `0x0000` en entrée.

Les `LC` et `MUX` ne correspondent pas à des composants mais sont considérés comme des branchements conditionnels en asynchrone.

Enfin, la gestion des aléas est un composant de supervision externe qui est branché sur les 3 premiers niveaux de pipelies. Il détecte un aléa si le premier étage veut lire un registre qui est écrit par l'étage 2 ou 3. En émettant le flag `alea` qui est propagé aux pipelines, des instructions `NOP` sont émises tant que l'aléa est détecté et ce comportement est directement intégré au sein du composant `Pipeline`.
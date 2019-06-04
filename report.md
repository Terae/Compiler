---
title: Projet Systèmes Informatiques
author: Benjamin BIGEY, Jérôme M M KOMPÉ
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
* Les fonctions `void printf(int)` et `void scanf(*int)` sont reconnues

## Génération du code assembleur

Notre implémentation actuelle ne prend pas en compte les pointeurs, les `string`s ni les opérateurs 'bitwise'. Cependant, la génération du code assembleur est opérationnelle pour le reste de la grammaire considérée, et on a modifié le jeu d'instructions pour supprimer les instructions `INFE`, `SUP` et `SUPE` car elles peuvent toutes découler de l'instruction `INF`.

On a également inséré les trois instructions suivantes :

Opération | Code | OP | A | B | C | Description | VHDL
----------|------|----|---|---|---|-----------|-----
Printf | 0xB | PRINT | @i | - | - | printf("%d", *i) | non
Scanf | 0xC | SCANF | Ri | - | - | [Ri] <- scanf() | non
Saut par registre | 0xD | JMPR | Ri | - | - | Saut à l'adresse [Ri] | oui

Nous utilisons  registres pour accomplir l'ensemble des opérations :

0. `R0`, un registre utilisable par un développeur avec sauvegarde du contexte
1. `R1`, un registre utilisable par un développeur avec sauvegarde du contexte
2. `R2`, un registre utilisable par un développeur avec sauvegarde du contexte
3. `ESP`, qui permets d'associer relativement une plage de mémoire à chaque fonction
4. `tmpR`, un registre sans sauvegarde du contexte qui est utilisé comme zone mémoire temporaire pour réaliser certaines opérations sans compromettre le contexte des autres registres

## L'interpréteur
L'interpréteur demandé pour le projet a également été réalisé, ce qui s'est avéré indispensable pour tester et corriger la génération de code.

Il est capable de lire du code assembleur sous forme de texte avec des commentaires : `ADD 3, 10 ; increases ebp`

# Microprocesseur
La seconde partie du projet consiste en la réalisation d'un microprocesseur de type RISC avec 4 niveaux de pipeline.

Nous avons utilisé le langage de description VHDL pour le réaliser sur une carte FPGA de type Spartan.

Le compilateur et le processeur que nous avons réalisés sont compatibles et orientés registres, même si nous n'avons pas eu le temps d'exécuter des instructions en réel sur la carte FPGA et donc l'ensemble de la chaîne de l'écriture d'un code C à son exécution par le microprocesseur n'a pas pu être validée.

### Démarche globale
Comme conseillé, nous avons réalisé notre microprocesseur par étapes. Dans un premier temps, nous avons développé individuellement chaque composant. Ensuite, après les avoir testé, nous les avons intégré ensemble en nous inspirant du schéma de conception du processeur.

Nous avons pu tester en simulation l'ensemble des instructions et l'ensemble du processeur nous semble valide.

### Les choix d'implémentation
Sachant que chaque pipeline du chemin de données sont synchrones, nous avons privilégié un développement asynchrone pour chaque composant pour minimiser la temporisation. Ainsi, seuls le compteur IP, la gestion des aléas et les écritures en mémoire sont synchrones.

Nous avons fait le choix de créer un module distinct pour chaque composant pour gagner en lisibilité lors de la phase de test. De plus, ce choix nous a permis de pouvoir instantier plusieurs fois un même module.
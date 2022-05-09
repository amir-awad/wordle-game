main:-
    write("Welcome to Pro-Wordle!"),nl,
    write("----------------------"),nl,nl,
    build_kb,
    play.


build_kb:-
    write("Please enter a word and its category on separate lines:"),nl,
    read(W),
    (
        W = done,nl,write("Done building the words database..."),nl,nl;
        read(C),
        assert(word(W,C)),
        build_kb
    ).

play:-
    choose_and_play.

% The player has to choose a length,which exists in the KB, of some word and its Category.
choose_and_play:-
    nl,
    categories(AllCategories),
    write("The available categories are:"),
    write(AllCategories),nl,
    choose_category(C),
    choose_length(Len,C),
    write("Game started. You have "),
    N is Len+1,
    write(N),
    write(" guesses."),nl,nl,
    pick_word(W,Len,C),
    start_guessing(Len,N,W).


start_guessing(L,N,W):-
    write("Enter a word composed of "), 
    write(L),
    write(" letters:"),nl,
    read(G),
    (
        ((N>=1,W == G,write("You Won!")));(N==1,W \== G,write("You Lost!"));
        

        (string_length(G,GL),GL\=L,write("Word is not composed of 5 letters. Try again."),nl,
         write("Remaining Guesses are "),write(N),nl,nl,start_guessing(L,N,W));

    (
        N1 is N-1,
        string_to_list(W, WL),
        string_to_list(G, GL),

        correct_letters(WL,GL,LL),
        list_to_set(LL,Letters),

        atom_codes(A,Letters),
        atom_chars(A,Chars),

        write("Correct letters are: "),
        write(Chars),nl,

        correct_positions(WL,GL,Positions),

        atom_codes(B,Positions),
        atom_chars(B,Pos),
        write("Correct letters in correct positions are: "),
        write(Pos),nl,

        write("Remaining Guesses are "),
        write(N1),nl,nl,

        start_guessing(L,N1,W)
    )

    ).

choose_category(C):-
    write("choose a category:"),nl,
    read(Category),
    (   
        C = Category,is_category(Category);
        write("This category does not exist."),nl,
        choose_category(C)
    ).

choose_length(Len,C):-
    write("choose a length:"),nl,
    read(Length),
    (
        Len = Length, available_length(Length,C);
        write("There are no words of this length."),nl,
        choose_length(Len,C)
    ).


is_category(C):-
    word(_,C).

categories(C):-
    setof(V,is_category(V),C).

available_length(L):-
    word(W,_),
    string_length(W,L),!.

available_length(L,C):-
    word(W,C),
    string_length(W,L),!.

pick_word(W,L,C):-
    word(W,C),
    string_length(W,L),!.

correct_letters([],L,[]).
correct_letters([H|T],L,CL):-
    member(H,L),
    CL = [H|Y],
    correct_letters(T,L,Y).

correct_letters([H|T1],L,CL):-
    \+member(H,L),
    correct_letters(T1,L,CL).

correct_positions([],_,[]):-!.
correct_positions(_,[],[]):-!.
correct_positions([H1|T1],[H2|T2],PL):- H1=H2,PL = [H1|Y],correct_positions(T1,T2,Y).
correct_positions([H1|T1],[H2|T2],PL):- H1\=H2,correct_positions(T1,T2,PL).
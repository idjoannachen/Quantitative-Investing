%% make_table.m
%% Purpose: Create tables--i.e., with row and column headings--in Matlab
%% By Raife Giovinazzo
%% 10-18-04

function make_table(Row_Heads,Col_Heads, Data, Col_Width, Decimals);
%% Row_Heads is a matrix, i.e., use [] and each row must be same length
%% Row_Heads requires a string to go on the row with the column headings
%% Row_Heads must have at least as many entries as Data has rows
%% Col_Heads is a cell, i.e., use {} and each entry can be different length
%% Data is the data that's being put in the table
%% Col_Width is the number of characters in each column.  I suggest 10;
%% Decimals is how many decimal places to show.  E.g., 3.75 has 2 Decimals

%% SAMPLE USE OF THE PROGRAM
%% a = [1, 1, 1; 1, 2, 3; 2, 1, 1];
%% Row_Heads = ['       '; 'Agent 1'; 'Agent 2'; 'Agent 3'];
%% Col_Heads = {'Good 1'; 'Good 2'; 'Good 3'};
%% make_table(Row_Heads, Col_Heads, a, 10, 4); 

%% CALCULATE THE SIZE OF THE HEADINGS & DATA
Num_Cols_Headings = size(Col_Heads);
Num_Cols_Data = size(Data,2);
Num_Rows = size(Data,1);

%% MAKE THE TOP ROW
S = 'fprintf(''';
S = [S Row_Heads(1,:)];
for i = 1:Num_Cols_Headings;
    S = [S '%' num2str(Col_Width) 's '];
end
S = [S '\n'''];
for i = 1:Num_Cols_Headings;
    S = [S ',''' char(Col_Heads(i)) ''''];
end
S = [S ')'];
eval(S)

%% MAKE ALL THE OTHER ROWS
for j = 1:Num_Rows;
    S = 'fprintf(''';
    S = [S Row_Heads(j+1,:)];
    for i = 1:Num_Cols_Data;
        S = [S '%' num2str(Col_Width) '.' num2str(Decimals) 'f '];
    end
    S = [S '\n'', Data(' num2str(j) ',:))'];
    eval(S)
end
S = 'fprintf(''\n'')';
eval(S)

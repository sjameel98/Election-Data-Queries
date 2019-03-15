import java.sql.*;
import java.util.ArrayList;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
//import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    private Statement st = null;

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        try {
            connection = DriverManager.getConnection(url, username, password);
            st = connection.createStatement();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }

        return true;
    }

    @Override
    public boolean disconnectDB() {
        if(st != null) {
            try {
                st.close();
            } catch (SQLException e) {
                e.printStackTrace();
                return false;
            }
        }

        if(connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
                return false;
            }
        }

        return true;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        List<Integer> caid = new ArrayList<>();
        List<Integer> eid = new ArrayList<>();

        try {
            PreparedStatement ps = connection.prepareStatement(
                    "SELECT cabinet.id AS caid, cabinet.election_id as eid " +
                            "FROM cabinet, country " +
                            "WHERE country.id = cabinet.country_id AND country.name = ? " +
                            "ORDER BY cabinet.start_date DESC"
            );
            ps.setString(1, countryName);

            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                caid.add(rs.getInt("caid"));
                eid.add(rs.getInt("eid"));
            }

            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return new ElectionCabinetResult(eid, caid);
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        List<Integer> res = new ArrayList<>();
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ps = connection.prepareStatement(
                    "SELECT id " +
                            "FROM politician_president " +
                            "WHERE id <> ?"
            );
            ps.setInt(1, politicianName);
            rs = ps.executeQuery();
            while(rs.next()) {
                res.add(rs.getInt("id"));
            }

            String politicianText = null;
            ps = connection.prepareStatement(
                    "SELECT comment, description " +
                            "FROM politician_president " +
                            "WHERE id = ?"
            );
            ps.setInt(1, politicianName);
            rs = ps.executeQuery();
            while(rs.next()) {
                politicianText = rs.getString("comment") + " " + rs.getString("description");
            }

            for(int i = 0; i < res.size(); i++) {
                Integer id = res.get(i);
                String text = null;
                ps.setInt(1, id);
                rs = ps.executeQuery();
                while(rs.next()) {
                    text = rs.getString("comment") + " " + rs.getString("description");
                }

                double score = similarity(text, politicianText);
                System.out.println(score);
                if(score < threshold) {
                    res.remove(i--);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return res;
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");

        Assignment2 a = null;

        try {
            a = new Assignment2();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            System.exit(0);
        }

        a.connectDB("jdbc:postgresql://localhost:5432/morris", "morris", "");
        a.disconnectDB();
    }

}

